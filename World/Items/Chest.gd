extends Area2D

const ExplosionEffect = preload("res://Effects/Explosion.tscn")
const DiamondScene = preload("res://World/Items/Diamond.tscn")

export var MAX_HEALTH = 15
export var HEALTH = 15
export var ARMOUR = 5

onready var health_bar: TextureProgress = $HealthBar

func _ready():
	health_bar.max_value = MAX_HEALTH
	health_bar.value = HEALTH

func _on_Chest_area_entered(area):
	
	var damage_taken = Character.get_damage(ARMOUR)
	HEALTH -= damage_taken
	
	if HEALTH > 0:
		health_bar.value = HEALTH
		print("new health", HEALTH)
		return
	
	Utils.instance_scene_on_main(ExplosionEffect, position)
	spawn_diamonds()
	queue_free()
	
func spawn_diamonds():
	var amount = randi() % 3 + 1
	for i in range(amount):
		Utils.instance_scene_on_main(DiamondScene, position)
