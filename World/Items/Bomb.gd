extends KinematicBody2D

export (int) var GRAVITY = 25
export (int) var FRICTION = 0.25

var motion = Vector2()
var is_thrown = false
var is_ticking = false
var is_exploding = false
var last_y

onready var pickup: Area2D = $Pickup
onready var pickup_collision_shape: Area2D = $Pickup/CollisionShape
onready var explosion_collision_shape: Area2D = $Explosion/CollisionShape
onready var sprite: AnimatedSprite = $Sprite
onready var timer: Timer = $Timer

func init(value: Vector2):
	# assign initial motion
	motion = value
	
	# disable enemy pickup when thrown
	is_thrown = true
	pickup_collision_shape.disabled = true
	last_y = position.y
	
func _process(delta):
	
	if is_exploding and sprite.frame == sprite.frames.get_frame_count("Boom") - 1:
		queue_free()

func _physics_process(delta):
	_apply_gravity(delta)
	_apply_sprite()
	
	# determine landed
	if last_y != position.y and is_thrown and not is_ticking:
		print("start ticking")
		# start ticking
		is_ticking = true
		timer.start()
	else:
		last_y = position.y
	
	move_and_collide(motion)

func _apply_gravity(delta):
	# apply gravity
	motion.y += delta * GRAVITY

func _apply_sprite():
		
	if is_exploding:
		sprite.play("Boom")
		return
	
	if is_ticking:
		sprite.play("On")
		return
	
	sprite.play("Idle")

func _on_Pickup_area_entered(area):
	if not is_thrown:
		queue_free()

func _on_Timer_timeout():
	explosion_collision_shape.disabled = false
	is_exploding = true
