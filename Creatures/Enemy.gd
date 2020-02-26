extends KinematicBody2D

const TILE_SIZE = 32

export var GRAVITY = 400
export var WALK_SPEED = 300
export var JUMP_FORCE = 200
export var MAX_JUMP_FORCE = -400
export var JUMP_TIMEOUT = 0.5
export var DOUBLE_JUMP_MULTIPLIER = 0.25

var is_jumping = false
var just_jumped = false
var motion = Vector2()

var is_ai = true
var is_ai_attacking = false
var is_ai_attacking_cooldown = false

const ATTACK_COOLDOWN = 1
const VIEW_DISTANCE = 4 * TILE_SIZE
const MELEE_DISTANCE = TILE_SIZE * 1
const MIN_MELEE_DISTANCE = TILE_SIZE * 0.4

onready var sprite: AnimatedSprite = $Sprite
onready var jump_timer: Timer = $JumpTimer
onready var some_timer: Timer = $SomeTimer

onready var attack_animator: AnimationPlayer = $Attack/AttackAnimator
onready var attack_timer: Timer = $Attack/AttackTimer

onready var walkable_left: RayCast2D = $Walkable/Left
onready var walkable_right: RayCast2D = $Walkable/Right
onready var walkable_fall_left: RayCast2D = $Walkable/FallLeft
onready var walkable_fall_right: RayCast2D = $Walkable/FallRight

func _physics_process(delta):
	
	apply_gravity(delta)
	
	if not is_ai_attacking:
		apply_ai()
		apply_sprite_horizontal()
		apply_sprite_animation()
	else:
		motion.x = 0
	
	if motion.y < MAX_JUMP_FORCE:
		motion.y = MAX_JUMP_FORCE
		
	if is_on_floor() and is_jumping:
		is_jumping = false
	
	# We don't need to multiply motion by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(motion, Vector2(0, -1))

func apply_ai():	
	# block ai until timer run out
	if not is_ai:
		return
	
	# block ai further on until timer timeout
	is_ai = false
	
	# update raycast positions
	var raycast_position = Vector2(position.x, position.y - 10)
	walkable_left.position = raycast_position
	walkable_right.position = raycast_position
	walkable_fall_left.position = raycast_position
	walkable_fall_right.position = raycast_position
	
	# character is dead, idle
	if Character.is_dead:
		ai_idle()
		return
	
	# player not in range
	var distance = position.distance_to(Character.character_position)
	if distance > VIEW_DISTANCE:
		ai_idle()
		return
		
	if position.distance_to(Character.character_position) <= MIN_MELEE_DISTANCE:
		if Character.character_position.x < position.x:
			walk_right()
		else:
			walk_left()
			return
	
	# can reach player for melee attack
	#var space_state = get_world_2d().direct_space_state
	#var result = space_state.intersect_ray(position, Character.character_position)
	var is_in_distance = position.distance_to(Character.character_position) <= MELEE_DISTANCE and position.distance_to(Character.character_position) >= MIN_MELEE_DISTANCE
	if is_in_distance and not is_ai_attacking_cooldown:
		
		# prepare attack
		is_ai_attacking = true
		is_ai_attacking_cooldown = true
		attack_timer.start(ATTACK_COOLDOWN)
		sprite.play("Attack")
		
		# play animator
		if Character.character_position.x > position.x:
			attack_animator.play("Attack_Right")
			sprite.flip_h = false
		else:
			attack_animator.play("Attack_Left")
			sprite.flip_h = true
		
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

func ai_idle():
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
	
	elif motion.x < 0:
		# is moving in left direction
		if rand_i > 3 and can_walk_left():
			# continue movement
			walk_left()
		else:
			# stop movement
			motion.x = 0
	
	# is moving in a direction
	elif motion.x > 0:
		# is moving in right direction
		if rand_i > 3 and can_walk_right():
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
	if is_jumping:
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
	if is_ai_attacking:
		return
	
	# sprite animation run
	if motion.x != 0 and sprite.animation != "Run":
		sprite.play("Run")
	
	# sprite animation idle
	if motion.x == 0 and sprite.animation != "Idle":
		sprite.play("Idle")
	
	# sprite animation jump
	if is_jumping and sprite.animation != "Jump":
		sprite.play("Jump")

func _on_JumpTimer_timeout():
	# reset jump timer
	just_jumped = false

func _on_SomeTimer_timeout():
	# reset ai timer
	is_ai = true
	some_timer.start()

func _on_AttackTimer_timeout():
	if is_ai_attacking:
		is_ai_attacking = false
		attack_timer.start(ATTACK_COOLDOWN)
		return
	
	if is_ai_attacking_cooldown:
		is_ai_attacking_cooldown = false
		return
