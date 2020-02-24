extends Node

var rng = RandomNumberGenerator.new()

func _randomize():
	rng.randomize()

func randi() -> int:
	_randomize()
	return rng.randi()

func randi_range(x, y) -> int:
	_randomize()
	return rng.randi_range(x, y)
