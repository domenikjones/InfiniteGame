extends KinematicBody2D

var gravity = 400
var motion = Vector2()
var is_jumping = false
var _move_and_collide = false

func _apply_gravity(delta):
	# apply vertical gravity
	motion.y += delta * gravity
	
	# reset is_jumping on floor
	if is_on_floor() and is_jumping:
		is_jumping = false

func _move():
	if _move_and_collide:
		move_and_collide(motion)
	else:
		move_and_slide(motion)
