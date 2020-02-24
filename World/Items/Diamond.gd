extends KinematicBody2D

export var DISAPPEAR_TIMER = 5
export var REWARD_MIN = 1
export var REWARD_MAX = 10

onready var animator: AnimationPlayer = $DiamondAnimator
onready var timer: Timer = $Timer

func _ready():
	timer.start(DISAPPEAR_TIMER)

func _on_Hurtbox_body_entered(body):
	rand_reward()
	queue_free()
	
func rand_reward():
	var reward = randi() % REWARD_MAX + REWARD_MIN
	print("reward", reward)
	Character.collect_diamonds(reward)

func _on_Timer_timeout():
	animator.play("Disappear")
