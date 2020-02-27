extends Node2D

onready var sprite: AnimatedSprite = $Sprite
onready var timer: Timer = $Timer

var out = false
var offset_x = 0
var offset_y = 0
var animation = "Hey"

func _ready():
	# set position
	position.x += offset_x
	position.y = offset_y

func _process(delta):
	
	if not out and not sprite.animation == str(animation + "In"):
		sprite.play(animation + "In")
		return
		
	if not out and sprite.frame == sprite.frames.get_frame_count(animation + "In") - 1 and sprite.playing:
		sprite.stop()
		timer.start(2)
		return
		
	if out and not sprite.animation == str(animation + "Out"):
		sprite.play(animation + "Out")
		return
		
	if out and sprite.frame == sprite.frames.get_frame_count(animation + "Out") - 1 and sprite.playing:
		queue_free()

func _on_Timer_timeout():
	out = true
