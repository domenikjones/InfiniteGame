extends CanvasLayer

var paused: bool = false

onready var menu = $Menu

func pause():
	menu.visible = !menu.visible
	paused = !paused

func _on_BackToMenu_pressed():
	GameState.game_state = GameValues.GAME_STATES.GAME_MENU
