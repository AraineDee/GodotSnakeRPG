extends Node2D

class_name Snake

#region DECLARATIONS
@export var time_between_moves : float = 0.5
var move_timer : float = time_between_moves

signal move()
signal bounce()

signal got_pickup(pickup_coords : Vector2i)
signal hit_goal()
signal hit_burrow()
signal got_key()

signal burrowed()
signal died()

signal took_damage(new_health : int)

@export var SegmentScene : PackedScene

@onready var state_machine : FiniteStateMachine = $FiniteStateMachine

var segments : Array[Segment]= []
var num_segments := 0
@onready var desired_segments : int = SaveManager.desired_segments

var unstable_count : int = 0 #the number of segments that are unstable

enum DIRECTION {RIGHT, DOWN, LEFT, UP}

var dir : DIRECTION = DIRECTION.DOWN
var last_dir : DIRECTION = DIRECTION.DOWN
var steps = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
var step_mult = 64

var dazed := false
var falling := false
var burrowing := false
var is_burrowed := false
var unburrowing := false

var health : int = 3
#endregion

#region INITIALIZATIONS
func init_segment(seg : Segment):
	segments.append(seg)
	
	move.connect(seg.move)
	bounce.connect(seg.bounce)
	seg.new_chunk.connect(move_to_chunk)
	
	seg.set_next_step(steps[dir] * step_mult)
	seg.set_last_step(steps[dir] * step_mult)
	
	seg.hit_self.connect(_on_segment_hit_self)

#endregion

func move_to_chunk(chunk : Chunk):
	$Camera2D.position = chunk.position

#region INPUT
func get_next_step() -> Vector2i:
	var next_step = steps[dir] * step_mult
	return next_step
	
func turn_left():
	var new_dir : DIRECTION
	match dir:
		DIRECTION.RIGHT:
			new_dir = DIRECTION.UP
		DIRECTION.UP:
			new_dir = DIRECTION.LEFT
		DIRECTION.LEFT:
			new_dir = DIRECTION.DOWN
		DIRECTION.DOWN:
			new_dir = DIRECTION.RIGHT
	
	#if the different between them is 2, then they are facing different ways, and thats not allowed
	if abs(new_dir-last_dir) == 2:
		return
	dir = new_dir

func turn_right():
	var new_dir : DIRECTION
	match dir:
		DIRECTION.RIGHT:
			new_dir = DIRECTION.DOWN
		DIRECTION.DOWN:
			new_dir = DIRECTION.LEFT
		DIRECTION.LEFT:
			new_dir = DIRECTION.UP
		DIRECTION.UP:
			new_dir = DIRECTION.RIGHT
	
	#if the different between them is 2, then they are facing different ways, and thats not allowed
	if abs(new_dir-last_dir) == 2:
		return
	dir = new_dir

func set_dir(new_dir : DIRECTION):
	if abs(new_dir-last_dir) == 2 and not state_machine.current_state.name == "UnBurrowed":
		return
	dir = new_dir
	segments[0].next_step = get_next_step()

#endregion

#region COLLISION HANDLING
func _on_segment_hit_self(_seg : Segment, _other_seg : Segment):
	state_machine.change_state("Bounce")
	
func handle_pickup(_segment : Segment, type : int, pickup_coords : Vector2i):
	match type:
		0: #apple
			add_segment.call_deferred()
	
	got_pickup.emit(pickup_coords)

func handle_hazard_enter(_segment : Segment, type : int, _hazard_coords : Vector2i):
	match type:
		0: #solid
			state_machine.change_state("Bounce")
			take_damage(1)
		1: #pit
			state_machine.change_state("Bounce")

func handle_hazard_exit(_segment : Segment, _type : int, _hazard_coords : Vector2i):
	pass

func handle_interactable_enter(segment : Segment, type : int, tile_coords : Vector2i):
	match type:
		0: #burrow
			if state_machine.current_state.name != "Idle":
				return
			if segment.is_head:
				state_machine.change_state("Burrowing")
		1: #bridge
			unstable_count += 1
		2: #apple tree
			print("entered apple tree")
			state_machine.change_state("Bounce")
			take_damage(1)
			get_parent().apple_tree(segment, tile_coords)


func handle_interactable_exit(_segment : Segment, type : int, _tile_coords : Vector2i):
	match type:
		1: #bridge
			unstable_count -= 1

#endregion

#region SEGMENT ADDING/REMOVING
func add_segment():
	var new_segment = SegmentScene.instantiate() as Segment
	add_child(new_segment)
	num_segments += 1
	init_segment(new_segment)
	if num_segments == 1:
		new_segment.set_as_head()
		return
	var tail = segments[-2]
	tail.moved.connect(new_segment.set_next_step)
	new_segment.bounced.connect(tail.set_last_step)
	new_segment.position = tail.position - tail.last_step

func remove_segment(id : int):
	assert(id >= 0 and id < num_segments, "ID must be valid number")
	var removed = segments.pop_at(id) as Segment
	removed.queue_free()
	num_segments -= 1
	if id == 0 and num_segments > 0:
		segments[0].set_as_head()	
	if id != 0 and id < num_segments:
		segments[id].bounced.connect(segments[id-1].set_last_step)
		segments[id-1].moved.connect(segments[id].set_next_step)

#endregion

func respawn(chunk : Chunk, coords : Vector2i):
	var respawn_state = get_child(1).get_child(10)
	respawn_state.chunk = chunk
	respawn_state.coords = coords
	state_machine.change_state("Respawning")

func unburrow():
	state_machine.change_state("UnBurrowed")

func take_damage(damage : int):
	health -= damage
	took_damage.emit(health)
	if health <= 0:
		died.emit()
