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


@export var SegmentScene : PackedScene

@onready var state_machine : FiniteStateMachine = $FiniteStateMachine

var segments : Array[Segment]= []
var num_segments := 3
var desired_segments := 3

var segment_stability := 0

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
#endregion

#region INITIALIZATIONS
# Called when the node enters the scene tree for the first time.
func _ready():
	for seg in get_tree().get_nodes_in_group("SnakeSegment"):
		init_segment(seg)
	segments[0].enable_entity_monitoring()


func init_segment(seg : Segment):
	segments.append(seg)
	
	move.connect(seg.move)
	bounce.connect(seg.bounce)
	
	seg.set_next_step(steps[dir] * step_mult)
	seg.set_last_step(steps[dir] * step_mult)
	
	seg.stability_changed.connect(_on_segment_stability_changed)
	seg.hit_self.connect(_on_segment_hit_self)

#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float):
	pass
	#if burrowing and num_segments == 0:
		#burrowing = false
		#is_burrowed = true
		#burrowed.emit()
	#
	#if is_burrowed:
		#return
	#
	#if not burrowing and not is_burrowed:
		#$Camera2D.position = segments[0].position
	#if(move_timer <= 0):
		#move_timer = time_between_moves
		#if burrowing:
			#_remove_segment(0)
			#if num_segments <= 0:
				#return
			#
		#_check_stability()
		#if falling and not dazed:
			#died.emit()
		#
		#segments[0].set_next_step(steps[dir]  * step_mult)
		#if not dazed:
			#move.emit()
			#last_dir = dir
		#dazed = false
		#
	#move_timer -= delta

func _do_bounce():
	if dazed:
		return
	dir = last_dir
	bounce.emit()
	dazed = true

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
	dir = new_dir
	segments[0].next_step = get_next_step()

#endregion

func toggle_cam():
	$Camera2D.enabled = !$Camera2D.enabled

func unburrow():
	state_machine.change_state("UnBurrowed")

#region COLLISION HANDLING
func handle_wall_collision(_wall_coords : Vector2i):
	state_machine.change_state("Bounce")

func _on_segment_hit_self(_seg : Segment, _other_seg : Segment):
	state_machine.change_state("Bounce")
	
func handle_pickup(type : int, pickup_coords : Vector2i):
	match type:
		0: #apple
			add_segment.call_deferred()
		1: #unapple
			remove_segment.call_deferred(num_segments-1)
		2: #key
			got_key.emit()
	
	got_pickup.emit(pickup_coords)

func handle_interactable(type : int, _tile_coords : Vector2i):
	match type:
		0: #goal
			hit_goal.emit()
		1: #burrow
			if state_machine.current_state.name != "Idle":
				return
			state_machine.change_state("Burrowing")

#endregion

#region SEGMENT ADDING/REMOVING
func add_segment():
	var new_segment = SegmentScene.instantiate() as Segment
	add_child(new_segment)
	num_segments += 1
	init_segment(new_segment)
	if num_segments == 1:
		return
	var tail = segments[-2]
	tail.moved.connect(new_segment.set_next_step)
	new_segment.bounced.connect(tail.set_last_step)
	new_segment.position = tail.position - tail.last_step
	
	
func remove_segment(id : int):
	assert(id >= 0 and id < num_segments, "ID must be valid number")
	var removed = segments.pop_at(id) as Segment
	removed.queue_free()
	if id != 0 and id != num_segments-1:
		segments[id].bounced.connect(segments[id-1].set_last_step)
		segments[id-1].moved.connect(segments[id].set_next_step)
	num_segments -= 1

#endregion

func move_segment_to_burrow():
	var chunk = get_parent().chunk_is_loaded(get_parent().chunk_offset) as Chunk
	#get cells in interactable layer
	var interactable_coords = chunk.get_used_cells(2)
	#loop through coords to find burrow
	for tile_coords in interactable_coords:
		if chunk.get_cell_tile_data(2, tile_coords).get_custom_data("InteractableType") == 1:
			segments[0].position = chunk.map_to_local(tile_coords)


func _check_stability():
	if segment_stability == num_segments:
		falling = true
		print("died")

func _on_segment_stability_changed(_seg : Segment, new_stability : int):
	if new_stability == 1:
		segment_stability += 1
	if new_stability == 0:
		segment_stability -= 1
