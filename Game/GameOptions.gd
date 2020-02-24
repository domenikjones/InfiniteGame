extends Node

onready var show_health_bar_button: CheckButton = $Center/VBox/ShowHealthBarButton

func _on_Easy_pressed():
	GameState.game_mode = GameValues.GAME_MODES.EASY

func _on_Medium_pressed():
	GameState.game_mode = GameValues.GAME_MODES.MEDIUM

func _on_Hard_pressed():
	GameState.game_mode = GameValues.GAME_MODES.HARD

func _on_Back_pressed():
	GameState.game_state = GameValues.GAME_STATES.GAME_MENU

func _on_ShowHealthBarButton_pressed():
	GameState.show_health_bars = show_health_bar_button.is_pressed()
