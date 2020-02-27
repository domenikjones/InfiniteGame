extends KinematicBody2D

var counter = 0

var motion = Vector2()
var is_jumping = false
var just_jumped = false

var health = 10
var has_bomb = false
var is_dead = false

var is_ai = true
var is_ai_alerted = false
var is_ai_attacking = false
var is_ai_attacking_cooldown = false
var is_ai_throwing = false

const TILE_SIZE = 32
const VIEW_DISTANCE = 4 * TILE_SIZE

const AI_COOLDOWN = .1
const ATTACK_COOLDOWN = 1
const THROW_COOLDOWN = 0.25
const MELEE_DISTANCE = TILE_SIZE * 0.85
const MIN_MELEE_DISTANCE = TILE_SIZE * 0.25
const THROW_DISTANCE = TILE_SIZE * 4
const MIN_THROW_DISTANCE = TILE_SIZE * 1.5

const GRAVITY = 400
const WALK_SPEED = 300
const JUMP_FORCE = 200
const MAX_JUMP_FORCE = -400
const JUMP_TIMEOUT = 0.5
const DOUBLE_JUMP_MULTIPLIER = 0.25

onready var dialog_scene = preload("res://Creatures/Misc/Dialog.tscn")
onready var diamond_scene = preload("res://World/Items/Diamond.tscn")
onready var heart_scene = preload("res://World/Items/Heart.tscn")
onready var bomb_scene = preload("res://World/Items/Bomb.tscn")

onready var sprite: AnimatedSprite = $Sprite

onready var jump_timer: Timer = $Timers/JumpTimer
onready var some_timer: Timer = $Timers/SomeTimer
onready var attack_timer: Timer = $Timers/AttackTimer
onready var death_timer: Timer = $Timers/DeathTimer
onready var throw_timer: Timer = $Timers/ThrowTimer

onready var health_bar: TextureProgress = $HealthBar
onready var attack_animator: AnimationPlayer = $EnemyAttack/AttackAnimator
onready var attack_collosion_shape: Area2D = $EnemyAttack/CollisionShape

onready var walkable_left: RayCast2D = $Walkable/Left
onready var walkable_right: RayCast2D = $Walkable/Right
onready var walkable_fall_left: RayCast2D = $Walkable/FallLeft
onready var walkable_fall_right: RayCast2D = $Walkable/FallRight
onready var collectable_left: RayCast2D = $Collectable/Left
onready var collectable_right: RayCast2D = $Collectable/Right

func _spam_log(string: String):
	return
	if (counter % 25 == 0):
		print(string)

func _ready():
	health_bar.max_value = health

func _physics_process(delta):
	counter += 1
	apply_gravity(delta)
	
	# register jump ended
	if is_on_floor() and is_jumping:
		is_jumping = false
	
	if health <= 0:
		motion.x = 0
		die()
	
	# we let the ai work (attacking_cooldown might still be active)
	if not is_ai_attacking and not is_ai_throwing:
		apply_ai(delta)
		apply_sprite_horizontal()
		apply_sprite_animation()
	else:
		# slow down to zero
		motion.x = 0
	
	# set some restrictions for motion
	motion.y = clamp(motion.y, -JUMP_FORCE, JUMP_FORCE)
	
	# We don't need to multiply motion by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(motion, Vector2(0, -1))

func die():
	if not is_dead:
		is_dead = true
		health_bar.queue_free()
		attack_collosion_shape.disabled = true
		sprite.play("Die")
		_add_dialog("Wtf")
	
	elif sprite.frame == sprite.frames.get_frame_count("Die") - 1 and sprite.playing:
		spawn_reward()
		sprite.stop()
		death_timer.start(3)

func apply_ai(delta):
	# block ai until timer run out
	if not is_ai or is_dead:
		# break the ai loop
		return
	
	# block ai further on until timer timeout
	is_ai = false
	
	# update raycast positions
	var raycast_position = Vector2(position.x, position.y - 10)
	walkable_left.position = raycast_position
	walkable_right.position = raycast_position
	walkable_fall_left.position = raycast_position
	walkable_fall_right.position = raycast_position
	collectable_left.position = raycast_position
	collectable_right.position = raycast_position
	
	# character is dead, idle
	if Character.is_dead:
		ai_idle()
		# break the ai loop
		return
		
	# collect items
	if collect_items():
		# break the ai loop
		return
	
	# player not in range
	var distance = position.distance_to(Character.character_position)
	if distance > VIEW_DISTANCE:
		ai_idle()
		# break the ai loop
		return
	
	# in view distance
	#print("in view distance ", distance)
	
	# show dialog if new alerted
	if not is_ai_alerted:
		is_ai_alerted = true
		_add_dialog("Hey")
	
	# attack ai (without is_ai_attacking_cooldown)
	var is_in_melee_distance = distance <= MELEE_DISTANCE and distance >= MIN_MELEE_DISTANCE
		
	# player is too close for bomb attack
	if not is_ai_attacking_cooldown and has_bomb and distance <= MIN_THROW_DISTANCE:
		# walk aside
		if Character.character_position.x < position.x:
			walk_right()
		else:
			walk_left()
		# break the ai loop
		return
		
	# throw bomb
	if not is_ai_attacking_cooldown and has_bomb and distance < THROW_DISTANCE:
		throw_bomb(distance, Character.character_position)
		return
	
	# player is too close for melee attack
	if not is_ai_attacking_cooldown and distance <= MIN_MELEE_DISTANCE:
		# walk aside
		if Character.character_position.x < position.x:
			walk_left()
		else:
			walk_right()
		# break the ai loop
		return
	
	# player is in melle attack distance
	if not is_ai_attacking_cooldown and distance < MELEE_DISTANCE:
		# prepare attack
		is_ai_attacking = true
		is_ai_attacking_cooldown = true
		attack_timer.start(ATTACK_COOLDOWN)
		
		# play attack anim
		sprite.play("Attack")
		
		# play animator
		if Character.character_position.x > position.x:
			attack_animator.play("Attack_Right")
			sprite.flip_h = true
		else:
			attack_animator.play("Attack_Left")
			sprite.flip_h = false
		
		# break the ai loop
		return
	
	# if we atticking cooldown is active, but could attack, we wait
	if is_ai_attacking_cooldown:
		return
	
	# walk towards player
	if Character.character_position.x < position.x:
		walk_left()
		if has_wall_left():
			jump()
	else:
		walk_right()
		if has_wall_right():
			jump()

func collect_items():
	can_collect_left()
	
	if has_collectable_left():
		walk_left()
		return true
	
	if has_collectable_right():
		walk_right()
		return true
	
	return false
	
func can_collect_left():
	if has_collectable_left():
		var col = collectable_left.get_collider()

func has_collectable_left():
	return collectable_left.is_colliding()

func has_collectable_right():
	return collectable_right.is_colliding()

func ai_idle():
	is_ai_alerted = false
	
	var rand_i = Rng.randi() % 10 + 1
	var rand_j = Rng.randi() % 10 + 1
	
	# not moving yet
	if motion.x == 0:
		# idle at position
		if rand_i > 4:
			return
		
		# can only walk left
		if not can_walk_right() and can_walk_left():
			walk_left()
			return
		
		# can only walk right
		if not can_walk_left() and can_walk_right():
			walk_right()
			return
		
		# walk to either side
		if rand_j > 5 and can_walk_right():
			walk_right()
		else:
			if can_walk_left():
				walk_left()
			else:
				# can not walk, possible loop hole
				pass
	
	# is moving in left direction
	elif motion.x < 0:
		if rand_i > 2 and can_walk_left():
			# continue movement
			walk_left()
		else:
			# stop movement
			motion.x = 0
	
	# is moving in right direction
	elif motion.x > 0:
		if rand_i > 2 and can_walk_right():
			# continue movement
			walk_right()
		else:
			# stop movement
			motion.x = 0
	else:
		# uncaptured, stop movement
		motion.x = 0

func walk_left():
	motion.x = -WALK_SPEED * 0.25

func walk_right():
	motion.x = WALK_SPEED * 0.25
	
func jump():
	# not jump while jumping or has a bomb
	if is_jumping or has_bomb:
		return
	
	is_jumping = true
	just_jumped = true
	jump_timer.start(JUMP_TIMEOUT)
	motion.y -= JUMP_FORCE

func can_walk_left() -> bool:
	if not walkable_fall_left.is_colliding():
		return false
	if walkable_left.is_colliding():
		return false
	return true

func can_walk_right() -> bool:
	if not walkable_fall_right.is_colliding():
		return false
	if walkable_right.is_colliding():
		return false
	return true
	
func has_wall_left():
	return walkable_left.is_colliding()
	
func has_wall_right():
	return walkable_right.is_colliding()

func apply_gravity(delta):
	# apply gravity
	motion.y += delta * GRAVITY
	
	# remove gravity on floor
	if is_on_floor():
		motion.y = 0
		if is_jumping:
			is_jumping = false

func apply_sprite_horizontal():
	# sprite horizontal orientation
	if motion.x > 0:
		sprite.flip_h = true
		sprite.position.x = 0
	if motion.x < 0:
		sprite.flip_h = false
		sprite.position.x = -5

func apply_sprite_animation():
	# dont overwrite blocked animated states
	if is_ai_attacking or is_ai_throwing or is_dead:
		return
	
	# sprite animation jump
	if is_jumping:
		if not sprite.animation == "Jump":
			sprite.play("Jump")
		return
	
	# sprite animation run
	if motion.x != 0:
		if has_bomb == true:
			if not sprite.animation == "BombRun":
				sprite.play("BombRun")
		else:
			if not sprite.animation == "Run":
				sprite.play("Run")
		return
	
	# sprite animation idle
	if motion.x == 0:
		if has_bomb == true:
			if not sprite.animation == "BombIdle":
				sprite.play("BombIdle")
		else:
			if not sprite.animation == "Idle":
				sprite.play("Idle")
		return

func _on_HurtBox_area_entered(area: Area2D):
	# picked up bomb
	if area.name == "Pickup":
		has_bomb = true
	
	# player attack
	if area.collision_layer == 0 and area.name == "Attack" and not is_dead:
		health -= Rng.randi_range(4, 7)
		health_bar.value = health
		return

func _on_DeathTimer_timeout():
	queue_free()

func _add_dialog(animation):
	var dialog = dialog_scene.instance()
	dialog.animation = animation
	dialog.offset_x = 0
	dialog.offset_y = - (TILE_SIZE * .85)
	add_child(dialog)

func spawn_reward():
	var rand_i = Rng.randi() % 10 + 1
	if rand_i > 8:
		Utils.instance_scene_on_main(heart_scene, position)
	elif rand_i > 4:
		Utils.instance_scene_on_main(diamond_scene, position)

func throw_bomb(distance, to):	
	# ai variables
	has_bomb = false
	is_ai_throwing = true
	is_ai_attacking = true
	is_ai_attacking_cooldown = true
	attack_timer.start(ATTACK_COOLDOWN)
	throw_timer.start(THROW_COOLDOWN)
	sprite.play("BombThrow")
	
	# spawn bomb
	var bomb = Utils.instance_scene_on_main(bomb_scene, position)
	var x = 2 + ((distance / TILE_SIZE)  * 0.25)
	var y = -6 - ((distance / TILE_SIZE) * 0.25)
	if to.x < position.x:
		x = -x
	bomb.init(Vector2(x, y))

func _on_AttackTimer_timeout():
	# ai was attacking
	if is_ai_attacking:
		is_ai_attacking = false
		attack_timer.start(ATTACK_COOLDOWN)
		
	# ai had attack cooldown
	elif is_ai_attacking_cooldown:
		is_ai_attacking_cooldown = false

func _on_ThrowTimer_timeout():
	is_ai_throwing = false

func _on_JumpTimer_timeout():
	# reset jump timer
	just_jumped = false

func _on_SomeTimer_timeout():
	# reset ai timer
	is_ai = true
	some_timer.start(AI_COOLDOWN)
