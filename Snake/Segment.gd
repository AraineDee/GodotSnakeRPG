extends Node2D

class_name Segment

signal moved(last_step : Vector2)
signal bounced(next_step : Vector2)

signal hit_self(this_segment : Segment, other_segment : Segment)
signal new_chunk(chunk : Chunk)
var next_step : Vector2
var last_step : Vector2

var is_head : bool = false

func _ready():
	$TileMapCollider.hit_pickup.connect(get_parent().handle_pickup)
	$TileMapCollider.hit_hazard.connect(get_parent().handle_hazard_enter)
	$TileMapCollider.left_hazard.connect(get_parent().handle_hazard_exit)
	$TileMapCollider.hit_interactable.connect(get_parent().handle_interactable_enter)
	$TileMapCollider.left_interactable.connect(get_parent().handle_interactable_exit)

func set_next_step(step : Vector2):
	next_step = step

func set_last_step(step : Vector2):
	last_step = step

func set_as_head():
	is_head = true

func move():
	position += next_step
	moved.emit(Vector2(last_step))
	last_step = Vector2(next_step)
	
func bounce():
	position -= last_step
	bounced.emit(Vector2(next_step))
	next_step = Vector2(last_step)

func _on_entity_collider_area_entered(area):
	if area.get_parent() is Segment:
		hit_self.emit(self, area.get_parent())
	if area.get_parent() is Chunk:
		new_chunk.emit(area.get_parent())
