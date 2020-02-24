extends Node

func _change_scene(scene):
	get_tree().change_scene(scene)

func _add_to_scene(scene):
	get_tree().add_child(scene.instance())
