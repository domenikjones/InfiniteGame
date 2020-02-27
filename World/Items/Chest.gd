extends Area2D

const ExplosionEffect = preload("res://Effects/Explosion.tscn")
const DiamondScene = preload("res://World/Items/Diamond.tscn")

export var MAX_HEALTH = 15
export var HEALTH = 15
export var ARMOUR = 5

onready var health_bar: TextureProgress = $HealthBar

func _ready():
	# set inital health bar values
	health_bar.max_value = MAX_HEALTH
	health_bar.value = HEALTH

func _on_Chest_area_entered(area):
	# allow only certain types of damage
	if not area.name == "Attack" or area.name == "Explosion":
		return
	
	# calculate the damage
	var damage_taken = Character.get_damage(ARMOUR)
	HEALTH -= damage_taken
	
	# alive
	if HEALTH > 0:
		health_bar.value = HEALTH
	
	# died
	else:
		Utils.instance_scene_on_main(ExplosionEffect, position)
		spawn_diamonds()
		queue_free()
	
func spawn_diamonds():
	# spawn random amount of diamonds
	var amount = randi() % 3 + 1
	for i in range(amount):
		Utils.instance_scene_on_main(DiamondScene, Vector2(position.x, position.y - GameValues.TILE_SIZE / 6))
