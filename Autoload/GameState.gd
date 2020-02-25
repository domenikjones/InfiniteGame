extends Node

onready var game_state setget set_game_state, get_game_state
onready var game_mode setget set_game_mode, get_game_mode

onready var show_health_bars: bool = true

# STATE

func _ready():
	print("GameState._ready")
	game_state = GameValues.GAME_STATES.GAME_MENU
	game_mode = GameValues.GAME_MODES.EASY
	
func _process(delta):
	#print(get_state_label(), get_mode_label())
	pass

func set_game_state(new_state):
	print("set_game_state() ", new_state)
	
	# stay in same state
	if new_state == game_state:
		print("current and new state is ", GameState.get_state_label())
		return
	
	# transition to another state
	print("change state from ", get_state_label(), " to ", get_state_label(new_state))
	
	# assign new value
	game_state = new_state
	
	# change to game menu
	if new_state == GameValues.GAME_STATES.GAME_MENU:
		GameScenes._change_scene("res://Game/GameMenu.tscn")
		Character.reset()
	
	# change to game options
	elif new_state == GameValues.GAME_STATES.GAME_OPTIONS:
		GameScenes._change_scene("res://Game/GameOptions.tscn")
		Character.reset()
	
	# change to ingame
	elif new_state == GameValues.GAME_STATES.WORLD:
		GameScenes._change_scene("res://World/World.tscn")
		Character.reset()
	
	# change to ingame
	elif new_state == GameValues.GAME_STATES.CREDITS:
		GameScenes._change_scene("res://Game/Credits.tscn")
		Character.reset()

func get_game_state():
	return game_state

func get_state_label(state = null):
	if state:
		return GameValues.GAME_STATES.keys()[state]
	return GameValues.GAME_STATES.keys()[game_state]

# MODE

func set_game_mode(new_mode):
	print("set_game_mode() ", new_mode)
	
	# stay in same state
	if new_mode == game_mode:
		print("current and new mode is ", GameState.get_mode_label())
		return
	
	# transition to another state
	print("change mode from ", get_mode_label(), " to ", get_mode_label(new_mode))
	
	# assign new value
	game_mode = new_mode

func get_game_mode():
	return game_mode

func get_mode_label(mode = null):
	if mode:
		return GameValues.GAME_MODES.keys()[mode]
	return GameValues.GAME_MODES.keys()[game_mode]
