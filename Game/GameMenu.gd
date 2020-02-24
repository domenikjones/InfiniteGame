extends Node


func _on_StartButton_pressed():
	GameState.game_state = GameValues.GAME_STATES.WORLD

func _on_OptionsButton_pressed():
	GameState.game_state = GameValues.GAME_STATES.GAME_OPTIONS

func _on_QuitButton_pressed():
	get_tree().quit()
