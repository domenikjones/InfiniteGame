extends Control

onready var score: Label = $CenterContainer/VBoxContainer/Score

func _process(delta):
	score.text = "Your Score: " + str(Character.diamonds)

func _on_Button_pressed():
	GameState.set_game_state(GameValues.GAME_STATES.GAME_MENU)
