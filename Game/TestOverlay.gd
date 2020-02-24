extends Node

onready var label = $CanvasLayer/Label
	
# warning-ignore:unused_argument
func _process(delta):
	set_label()
	
func set_label():
	label.text = "State: " + GameState.get_state_label() + \
		"\nMode: " + GameState.get_mode_label() + \
		"\nHearts: " + str(Character.hearts) + \
		"\nDiamonds: " + str(Character.diamonds) + \
		"\nHealth bars: " + str(GameState.show_health_bars)
