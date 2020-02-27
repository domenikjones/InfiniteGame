extends KinematicBody2D

export var DISAPPEAR_TIMER = 5
export var REWARD_MIN = 3
export var REWARD_MAX = 7

onready var animator: AnimationPlayer = $DiamondAnimator
onready var timer: Timer = $Timer

func _ready():
	timer.start(DISAPPEAR_TIMER)

func _on_Hurtbox_body_entered(body):
	rand_reward()
	queue_free()
	
func rand_reward():
	var life = randi() % REWARD_MAX + REWARD_MIN
	print("life ", life)
	Character.collect_life(life)

func _on_Timer_timeout():
	animator.play("Disappear")
