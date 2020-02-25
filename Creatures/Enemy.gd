extends KinematicBody2D

const TILE_SIZE = 32

export var GRAVITY = 400
export var WALK_SPEED = 300
export var JUMP_FORCE = 400
export var MAX_JUMP_FORCE = -400
export var JUMP_TIMEOUT = 0.5
export var DOUBLE_JUMP_MULTIPLIER = 0.25

var is_jumping = true
var just_jumped = true
var motion = Vector2()

var is_ai = true
var is_ai_attacking = false
const VIEW_DISTANCE = 4 * TILE_SIZE
const MELEE_DISTANCE = TILE_SIZE / 0.25

onready var sprite: AnimatedSprite = $Sprite
onready var jump_timer: Timer = $JumpTimer
onready var some_timer: Timer = $SomeTimer

onready var walkable_left: RayCast2D = $Walkable/Left
onready var walkable_right: RayCast2D = $Walkable/Right
onready var walkable_fall_left: RayCast2D = $Walkable/FallLeft
onready var walkable_fall_right: RayCast2D = $Walkable/FallRight

func _physics_process(delta):
	
	apply_gravity(delta)
	
	apply_ai()
	
	apply_sprite_horizontal()
	apply_sprite_animation()
	
	if motion.y < MAX_JUMP_FORCE:
		motion.y = MAX_JUMP_FORCE
	
	# We don't need to multiply motion by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	move_and_slide(motion, Vector2(0, -1))

func apply_ai():
	# block ai until timer run out
	if not is_ai:
		return
	
	# block ai further on until timer timeout
	is_ai = false
	
	# set raycast positions
	var raycast_position = Vector2(position.x, position.y - 10)
	walkable_left.position = raycast_position
	walkable_right.position = raycast_position
	walkable_fall_left.position = raycast_position
	walkable_fall_right.position = raycast_position
		
	# is player in range
	var distance = position.distance_to(Character.character_position)
	if distance > VIEW_DISTANCE:
		ai_idle()
		return
	
	# can reach player for melee attack
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, Character.character_position)
	if result and position.distance_to(result.position) > MELEE_DISTANCE:
		print("Melee Attack")
		
func ai_idle():
	var rand_i = Rng.randi() % 10 + 1
	var rand_j = Rng.randi() % 10 + 1
	print("ai_idle ", rand_i, " ", rand_j)
	print("walkable.left ", walkable_left.is_colliding(), " ", walkable_left.collide_with_areas, " ", walkable_left.enabled)
	print("walkable.right ", walkable_right.is_colliding(), " ", walkable_right.collide_with_areas, " ", walkable_right.enabled)
	#print("walkable.fall.left ", walkable_fall_left.is_colliding())
	#print("walkable.fall.right ", walkable_fall_right.is_colliding())
	
	# not moving yet
	if motion.x == 0:
		# idle at position
		if rand_i > 4:
			print("stay and continue to stay")
			return
		
		# can only walk left
		if not can_walk_right() and can_walk_left():
			print("can only walk left")
			walk_left()
			return
		
		# can only walk right
		if not can_walk_left() and can_walk_right():
			print("con only walk right")
			walk_right()
			return
		
		# walk to either side
		print("start to walk to a side")
		if rand_j > 5 and can_walk_right():
			walk_right()
		else:
			if can_walk_left():
				walk_left()
				
		print("could not start walk to a side")
		
	elif motion.x < 0:
		# is moving in left direction
		print("motion.x ", motion.x)
		# continue movement
		if rand_i > 3 and can_walk_left():
			walk_left()
			print("continue to walk in direction left")
		else:
			motion.x = 0
			print("do not walk more left")

	# is moving in a direction
	elif motion.x > 0:
		# is moving in right direction
		print("motion.x ", motion.x)
		# continue movement
		if rand_i > 3 and can_walk_right():
			walk_right()
			print("continue to walk in direction right")
		else:
			motion.x = 0
			print("do not walk more right")

func walk_left():
	motion.x = -WALK_SPEED * 0.25
	print("walk left")
	
func walk_right():
	motion.x = WALK_SPEED * 0.25
	print("walk right")

func can_walk_left() -> bool:
	if not walkable_fall_left.is_colliding():
		return false
	if walkable_left.is_colliding():
		return false
	return true
			
func can_walk_right() -> bool:
	if not walkable_fall_right.is_colliding():
		return false
	if walkable_right.is_colliding():
		return false
	return true

func apply_gravity(delta):
	# apply gravity
	motion.y += delta * GRAVITY
	
	# remove gravity on floor
	if is_on_floor():
		motion.y = 0
		if is_jumping:
			is_jumping = false

func apply_sprite_horizontal():
	# sprite horizontal orientation
	if motion.x > 0:
		sprite.flip_h = true
	if motion.x < 0:
		sprite.flip_h = false

func apply_sprite_animation():	
	# sprite animation run
	if motion.x != 0 and sprite.animation != "Run":
		sprite.play("Run")
	
	# sprite animation idle
	if motion.x == 0 and sprite.animation != "Idle":
		sprite.play("Idle")
	
	# sprite animation jump
	if is_jumping and sprite.animation != "Jump":
		sprite.play("Jump")

func _on_JumpTimer_timeout():
	# reset jump timer
	just_jumped = false

func _on_SomeTimer_timeout():
	# reset ai timer
	is_ai = true
	some_timer.start()
