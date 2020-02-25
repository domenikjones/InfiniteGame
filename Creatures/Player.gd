extends KinematicBody2D

export var MAX_HEALTH = 25
export var HEALTH = 1

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

onready var sprite: AnimatedSprite = $Sprite
onready var attack_animator: AnimationPlayer = $Attack/AttackAnimator
onready var jump_timer: Timer = $JumpTimer
onready var attack_timer: Timer = $AttackTimer
onready var death_timer: Timer = $DeathTimer
onready var health_bar: TextureProgress = $HealthBar

func _process(delta):
	if position.x > Character.score_width:
		Character.new_score_width(position.x)

func _physics_process(delta):
	# dead
	if HEALTH <= 0:
		die()
		return
	
	apply_gravity(delta)
	handle_input()
	apply_sprite_horizontal()
	apply_sprite_animation()
	
	if motion.y < MAX_JUMP_FORCE:
		motion.y = MAX_JUMP_FORCE
	
	# We don't need to multiply motion by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(motion, Vector2(0, -1))
	update_health_bar()
	
	# update character position
	Character.character_position = position

func die():
	if not is_dead:
		print("set animation")
		Character.is_dead = true
		is_dead = true
		sprite.play("Die")
		return
	
	print(" ")
	print("sprite.animation", sprite.animation)
	print("sprite.frame", sprite.frame)
	print("sprite.playing", sprite.playing)
	print("sprite.frame_count", sprite.frames.get_frame_count("Die"))
	
	if sprite.frame == sprite.frames.get_frame_count("Die") - 1 and sprite.playing:
		print("Death, frame count", sprite.frames.get_frame_count("Die"))
		sprite.stop()
		death_timer.start(3)

func update_health_bar():
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
	print("got hurt in the head")
	HEALTH -= 2
	health_bar.value = HEALTH

func _on_BodyHurtBox_area_entered(area):
	print("got hurt in the body")
	HEALTH -= 1
	health_bar.value = HEALTH
