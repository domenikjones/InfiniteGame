extends TextureProgress

func _process(delta):
	if GameState.show_health_bars:
		visible = true
	else:
		visible = false
