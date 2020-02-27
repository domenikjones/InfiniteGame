extends "res://World/KinematicBody2DGravity.gd"

export var DISAPPEAR_TIMER = 5
export var REWARD_MIN = 3
export var REWARD_MAX = 7

onready var animator: AnimationPlayer = $DiamondAnimator
onready var timer: Timer = $Timer

func _ready():
	timer.start(DISAPPEAR_TIMER)
	motion = Vector2(rand_range(-1,1), -.5)
	_move_and_collide = true
	gravity = 5
	
func _physics_process(delta):
	_apply_gravity(delta)
	_move()

func _on_Hurtbox_body_entered(body):
	rand_reward()
	queue_free()
	
func rand_reward():
	var life = randi() % REWARD_MAX + REWARD_MIN
	print("life ", life)
	Character.collect_life(life)

func _on_Timer_timeout():
	animator.play("Disappear")
