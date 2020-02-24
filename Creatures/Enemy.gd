extends KinematicBody2D

export var GRAVITY = 400
export var WALK_SPEED = 600
export var JUMP_FORCE = 400
export var MAX_JUMP_FORCE = -400
export var JUMP_TIMEOUT = 0.5
export var DOUBLE_JUMP_MULTIPLIER = 0.25

var is_jumping = true
var just_jumped = true
var motion = Vector2()

onready var sprite: AnimatedSprite = $Sprite
onready var jump_timer: Timer = $JumpTimer

func _physics_process(delta):
	
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

func apply_gravity(delta):
	# apply gravity
	motion.y += delta * GRAVITY
	
	# remove gravity on floor
	if is_on_floor():
		motion.y = 0
		if is_jumping:
			print("landed")
			is_jumping = false

func handle_input():
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
			print("jump")
		
		if just_jumped:
			# apply 25% jump force if double jump
			motion.y -= JUMP_FORCE * DOUBLE_JUMP_MULTIPLIER
			print("double jump")
		
		just_jumped = true
		is_jumping = true
		
		print("motion.y", motion.y)

func apply_sprite_horizontal():
	# sprite horizontal orientation
	if motion.x > 0:
		sprite.flip_h = true
	if motion.x < 0:
		sprite.flip_h = false

func apply_sprite_animation():	
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
	print("_on_JumpTimer_timeout")
	just_jumped = false
