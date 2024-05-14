extends Node2D

#region DECLARATIONS
@export var time_between_moves : float = 0.5
var move_timer : float = time_between_moves

signal move()
signal bounce()
signal got_pickup(pickup_coords : Vector2i)
signal hit_goal()
signal died()
signal got_key()

@export var SegmentScene : PackedScene

var segments := []
var num_segments := 3

var segment_stability := 0

var dir = 0
var last_dir := 0
var steps = [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]
var step_mult = 64

var dazed := false
var falling := false

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
	
	seg.set_next_step(steps[0] * step_mult)
	seg.set_last_step(steps[0] * step_mult)
	
	seg.stability_changed.connect(_on_segment_stability_changed)
	seg.hit_self.connect(_on_segment_hit_self)

#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	if(move_timer <= 0):
		_check_stability()
		if falling and not dazed:
			emit_signal("died")
		
		segments[0].set_next_step(steps[dir]  * step_mult)
		if not dazed:
			emit_signal("move")
			last_dir = dir
		dazed = false
		move_timer = time_between_moves
	move_timer -= delta

func _do_bounce():
	if dazed:
		return
	dir = last_dir
	emit_signal("bounce")
	dazed = true

#region INPUT
func _input(event):
	var new_dir = dir
	if event.is_action_pressed("Left"):
		new_dir = (dir + 1) % 4
	if event.is_action_pressed("Right"):
		new_dir = (dir - 1) % 4
	if abs(new_dir - last_dir) != 2:
		dir = new_dir

#endregion

#region COLLISION HANDLING
func handle_wall_collision(_wall_coords : Vector2i):
	_do_bounce()

func _on_segment_hit_self(_seg : Segment, _other_seg : Segment):
	_do_bounce()
	
func handle_pickup(type : int, pickup_coords : Vector2i):
	match type:
		0: #apple
			_add_segment.call_deferred()
		1: #unapple
			_remove_segment.call_deferred()
		2: #key
			emit_signal("got_key")
	
	emit_signal("got_pickup", pickup_coords)

func handle_interactable(type : int, _tile_coords : Vector2i):
	match type:
		0: #goal
			emit_signal("hit_goal")

#endregion

#region SEGMENT ADDING/REMOVING
func _add_segment():
	var new_segment = SegmentScene.instantiate() as Segment
	var tail = segments[-1]
	add_child(new_segment)
	num_segments += 1
	tail.moved.connect(new_segment.set_next_step)
	new_segment.bounced.connect(tail.set_last_step)
	new_segment.position = tail.position - tail.last_step
	init_segment(new_segment)
	
func _remove_segment():
	var tail = segments.pop_back() as Segment
	tail.queue_free()
	num_segments -= 1

#endregion



func _check_stability():
	if segment_stability == num_segments:
		falling = true

func _on_segment_stability_changed(_seg : Segment, new_stability : int):
	if new_stability == 1:
		segment_stability += 1
	if new_stability == 0:
		segment_stability -= 1
