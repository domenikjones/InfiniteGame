extends "res://World/KinematicBody2DGravity.gd"

var DISAPPEAR_TIMER: int = 5
var REWARD_MIN: int = 1
var REWARD_MAX: int = 10

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
	var diamonds = randi() % REWARD_MAX + REWARD_MIN
	Character.collect_diamonds(diamonds)

func _on_Timer_timeout():
	animator.play("Disappear")
