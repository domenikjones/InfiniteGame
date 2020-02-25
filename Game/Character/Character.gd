extends Node

var hearts = 0 setget set_hearts, get_hearts
var diamonds = 0 setget set_diamonds, get_diamonds
var score_width = 0 setget set_score_width, get_score_width

var character_position: Vector2 = Vector2()

export var BASE_DAMAGE = 1
export var STRENGTH = 23
export var DEXTERITY = 5

func set_score_width(value: int):
	print("CAN NOT SET SCORE VALUE")
	
func get_score_width():
	return score_width
	
func new_score_width(value: int):
	score_width = value
	
func set_diamonds(value: int):
	print("CAN NOT SET DIAMONDS VALUE")

func get_diamonds():
	return diamonds
	
func set_hearts(value: int):
	print("CAN NOT SET HEARTS VALUE")

func get_hearts():
	return hearts

func collect_diamonds(amount: int):
	if amount > 0:
		diamonds += amount


func get_damage(armour: int = 0, dex: int = 0) -> int:
	print("get_damage", armour, dex)
	var damage = BASE_DAMAGE
	
	# 0.5 per strength
	damage += STRENGTH * 0.5
	
	# 0.5 reduction per armour
	damage -= armour * 0.5
	
	print("damage", damage)
	return damage
