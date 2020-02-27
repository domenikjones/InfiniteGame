extends Node

var is_dead: bool = true
var health: int = 0 setget set_health, get_health
var diamonds: int = 0 setget set_diamonds, get_diamonds
var score_width: int = 0 setget set_score_width, get_score_width

var character_position: Vector2 = Vector2()
var add_life: int = 0

export (int) var BASE_DAMAGE = 1
export (int) var STRENGTH = 23
export (int) var DEXTERITY = 5

func reset():
	health = 25
	diamonds = 0
	score_width = 0
	is_dead = false
	
func set_health(value: int):
	print("CAN NOT SET HEALTH")
	
func get_health():
	return health

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

func collect_diamonds(amount: int):
	if amount > 0:
		diamonds += amount
		
func set_health_value(amount: float):
	health = amount

func collect_life(amount: int):
	if amount > 0:
		add_life = amount

func get_damage(armour: int = 0, dex: int = 0) -> int:
	print("get_damage", armour, dex)
	var damage = BASE_DAMAGE
	
	# 0.5 per strength
	damage += STRENGTH * 0.5
	
	# 0.5 reduction per armour
	damage -= armour * 0.5
	
	print("damage", damage)
	return damage
