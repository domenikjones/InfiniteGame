extends Node2D

const SCREEN_WIDTH = 22
const SCREEN_HEIGHT = 14

const START_OFFSET = SCREEN_WIDTH
const HEIGHT = 32
const MIN_HEIGHT = 3
const MAX_HEIGHT = 6
const BLOCK_SIZE = 24
const PRELOAD_BLOCKS = 1 #2 * SCREEN_WIDTH

var current_block = 0
var current_index = 3
var current_height = 5
var current_y = 6

onready var Chest = preload("res://World/Items/Chest.tscn")
onready var Enemy = preload("res://Creatures/Enemy.tscn")
onready var tile_map: TileMap = $TileMap
onready var tile_size = tile_map.cell_size

func _ready():
	_preload()
	
func _physics_process(delta):
	if Character.score_width > (current_block * BLOCK_SIZE * tile_size.x) - (2 * BLOCK_SIZE * tile_size.x):
		#print("reload block")
		_load_block()
	
	# foo bar 
	var tile_cell = tile_map.get_cell(0, 0)

func _preload():	
	for r in range(PRELOAD_BLOCKS):
		_load_block()

func get_better_y():
	if current_y < 6:
		return +1
	return -1

func _load_block():
	current_block += 1
	for r in range(BLOCK_SIZE):
		_load_column()

func _load_column():
	
	if Rng.randi() % 10 > 6:
		var rand_r = Rng.randi_range(-2, 2)
		var next_height = current_height + rand_r
		next_height = clamp(next_height, MIN_HEIGHT, MAX_HEIGHT)
		
		if current_height == next_height:
			pass
		elif current_height % 2 == 0:
			current_y -= 1
		elif current_height % 2 == 1:
			current_y -= 1
		
		current_height = next_height
	
	# assign background auto tile
	for i in range(current_height):
		tile_map.set_cell(current_index, current_y + i, 0)
		tile_map.update_bitmask_area(Vector2(current_index, current_y + i))
		
	# assign border tiles
	tile_map.set_cell(current_index, current_y - 1, 1)
	tile_map.update_bitmask_area(Vector2(1,2))
	tile_map.set_cell(current_index, current_y + current_height, 1)
	tile_map.update_bitmask_area(Vector2(1,0))
		
	# fill top and bottom
	for i in range(current_y - 30, current_y + current_height + 30):
		if tile_map.get_cell(current_index, i) == -1:
			tile_map.set_cell(current_index, i, 1)
			tile_map.update_bitmask_area(Vector2(current_index, i))
	
	# spawn chest
	var _chest = _spawn_chest()
	
	# spawn enemy 
	if not _chest:
		var _enemy = _spawn_enemy()
	
	current_index +=1

func _spawn_chest() -> bool:
	if Rng.randi() % 10 + 1 > 9:
		#print("[" + str(current_index) + "] spawn chest")
		var x = (current_index * tile_size.x) + (tile_size.x / 2)
		var y = (current_y * tile_size.x) + (current_height * tile_size.x)
		Utils.instance_scene_on_main(Chest, Vector2(x, y))
		return true
	return false

func _spawn_enemy() -> bool:
	if Rng.randi() % 100 + 1 > 95:
		#print("[" + str(current_index) + "] spawn enemy")
		var x = (current_index * tile_size.x) + (tile_size.x / 2)
		var y = (current_y * tile_size.x) + (current_height * tile_size.x) - 20
		Utils.instance_scene_on_main(Enemy, Vector2(x, y))
		return true
	return false
