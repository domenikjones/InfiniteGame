extends Node

const TIMER_INTERVAL = 5
const SPAWN_POSITIONS = 5

var spawn_positions: Array = []
onready var pos1: Position2D = $Pos1
onready var pos2: Position2D = $Pos2
onready var pos3: Position2D = $Pos3
onready var pos4: Position2D = $Pos4
onready var pos5: Position2D = $Pos5

onready var spawn: bool = false
onready var timer: Timer = $Timer

func _ready():
	spawn_positions.append(pos1)
	spawn_positions.append(pos2)
	spawn_positions.append(pos3)
	spawn_positions.append(pos4)
	spawn_positions.append(pos5)

func _physics_process(delta):
	if spawn:
		spawn()
		spawn = false

func spawn():
	var rand_int = randi()%SPAWN_POSITIONS+1
	print("spawn enemy at position " + str(rand_int) + " with mode " + GameState.get_mode_label())
	
func _on_Timer_timeout():
	spawn = true
