extends Node

onready var camera = $Camera
onready var player = $Player
onready var pause_menu = $PauseMenu
onready var level = $Level

export var score: float = 0
export var paused: bool = false

func _ready():
	pass

func _process(delta):
	handle_input()
	set_camera()
	
func set_camera():
	camera.position.x = player.position.x
	camera.position.y = player.position.y

func handle_input():
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.pause()
		paused = !paused
