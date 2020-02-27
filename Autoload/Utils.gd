extends Node

var counter = 0

func instance_scene_on_main(scene, position):
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.add_child(instance)
	instance.global_position = position
	return instance

func get_nodes_from_world(mask: String):
	var res = []
	var main = get_tree().current_scene
	for child in main.get_children():
		print("child", child)
		if child.name == mask:
			res.append(child)
	return res
