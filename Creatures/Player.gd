extends KinematicBody2D

export var MAX_HEALTH = 25
export var HEALTH = 25

export var GRAVITY = 600
export var WALK_SPEED = 200
export var JUMP_FORCE = 300
export var MAX_JUMP_FORCE = -400
export var JUMP_TIMEOUT = 0.75
export var DOUBLE_JUMP_MULTIPLIER = 0.5
export var ATTACK_COOLDOWN = 0.25

export var WIDTH = 720

var motion = Vector2()
var is_jumping = true
var is_dead = false
var just_jumped = true
var just_attacked = false

onready var center_position: Node2D = $Position
onready var sprite: AnimatedSprite = $Sprite
onready var attack_animator: AnimationPlayer = $Attack/AttackAnimator
onready var jump_timer: Timer = $JumpTimer
onready var attack_timer: Timer = $AttackTimer
onready var death_timer: Timer = $DeathTimer
onready var health_bar: TextureProgress = $HealthBar

func _ready():
	position = Vector2(-145, 280)

func _process(delta):		
	# collect life
	if Character.add_life > 0:
		HEALTH = clamp(HEALTH + Character.add_life, 0, MAX_HEALTH)
		Character.add_life = 0

func _physics_process(delta):
	
	# apply initial gravity in any state
	apply_gravity(delta)
	
	if HEALTH > 0:
		# handle player creature
		handle_input()
		apply_sprite_horizontal()
		apply_sprite_animation()
	else:
		# player died
		die()
		
	# set some restrictions for motion
	motion.y = clamp(motion.y, -JUMP_FORCE, JUMP_FORCE)
	
	# We don't need to multiply motion by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(motion, Vector2(0, -1))
	
	# update character health
	Character.set_health_value(HEALTH)
	update_health_bar()
	
	# update character position and score
	Character.character_position = center_position.global_position
	if position.x > Character.score_width:
		Character.new_score_width(position.x)

func die():
	if not is_dead:
		Character.is_dead = true
		is_dead = true
		sprite.play("Die")
		return
	
	if sprite.frame == sprite.frames.get_frame_count("Die") - 1 and sprite.playing:
		sprite.stop()
		death_timer.start(3)

func update_health_bar():
	# set the value for the health bar
	health_bar.max_value = MAX_HEALTH
	health_bar.value = HEALTH

func apply_gravity(delta):
	# apply gravity
	motion.y += delta * GRAVITY
	
	# remove gravity on floor
	if is_on_floor():
		motion.y = 0
		if is_jumping:
			is_jumping = false

func handle_input():
	# character is dead
	if Character.is_dead:
		return
		
	# handle attack
	if Input.is_action_just_pressed("attack") and not just_attacked:
		just_attacked = true
		attack_timer.start(ATTACK_COOLDOWN)
		sprite.play("Attack")
		if sprite.flip_h:
			attack_animator.play("Attack_Left")
		else:
			attack_animator.play("Attack_Right")
	# horizontal movement
	if Input.is_action_pressed("left"):
		motion.x = -WALK_SPEED
	elif Input.is_action_pressed("right"):
		motion.x =  WALK_SPEED
	else:
		motion.x = 0
	
	# jumping
	if Input.is_action_just_pressed("jump") and (not is_jumping or just_jumped):
		if not is_jumping:
			# start just jumped timer after default jump
			motion.y -= JUMP_FORCE
			jump_timer.start(JUMP_TIMEOUT)
		
		if just_jumped:
			# apply 25% jump force if double jump
			motion.y -= JUMP_FORCE * DOUBLE_JUMP_MULTIPLIER
		
		just_jumped = true
		is_jumping = true

func apply_sprite_horizontal():
	# sprite horizontal orientation	
	var rel = get_viewport().size.x / WIDTH
	var pos_x = get_viewport().get_mouse_position().x * rel
	
	# set sprite relative to mouse position in viewport (for pro aim)
	if pos_x > get_viewport().size.x / 2:
		sprite.flip_h = false
		sprite.position.x = 8
	else:
		sprite.flip_h = true
		sprite.position.x = -7

func apply_sprite_animation():
	# sprite animation run
	if motion.x != 0 and sprite.animation != "Run" and not just_attacked:
		sprite.play("Run")
	
	# sprite animation idle
	if motion.x == 0 and sprite.animation != "Idle" and not just_attacked:
		sprite.play("Idle")
	
	# sprite animation jump
	if is_jumping and sprite.animation != "Jump" and not just_attacked:
		sprite.play("Jump")

func _on_JumpTimer_timeout():
	just_jumped = false

func _on_AttackTimer_timeout():
	just_attacked = false

func _on_DeathTimer_timeout():
	GameState.set_game_state(GameValues.GAME_STATES.CREDITS)

func _on_HeadHurtBox_area_entered(area):
	if area.collision_layer == 2 and area.name == "EnemyAttack":
		var dmg = Rng.randi_range(2, 5)
		HEALTH -= dmg
		health_bar.value = HEALTH
		
	if area.name == "Explosion":
		var dmg = Rng.randi_range(4, 10)
		HEALTH -= dmg
		health_bar.value = HEALTH

func _on_BodyHurtBox_area_entered(area: Area2D):
	if area.collision_layer == 2 and area.name == "EnemyAttack":
		var dmg = Rng.randi_range(0, 2)
		HEALTH -= dmg
		health_bar.value = HEALTH
		
	if area.name == "Explosion":
		var dmg = Rng.randi_range(1, 5)
		HEALTH -= dmg
		health_bar.value = HEALTH
