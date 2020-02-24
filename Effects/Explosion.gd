extends Particles2D

onready var animator = $ExplosionAnimator

func _ready():
	animator.play("Explode")
