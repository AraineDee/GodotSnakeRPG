extends Node2D

class_name Segment

signal moved(last_step : Vector2)
signal bounced(next_step : Vector2)
signal stability_changed(this_segment : Segment, new_stability : int)
signal hit_self(this_segment : Segment, other_segment : Segment)

var next_step : Vector2
var last_step : Vector2

var unstable_counter := 0

func _ready():
	$TileMapCollider.hit_pickup.connect(get_parent().handle_pickup)
	$TileMapCollider.hit_wall.connect(get_parent().handle_wall_collision)
	$TileMapCollider.hit_interactable.connect(get_parent().handle_interactable)

func set_next_step(step : Vector2):
	next_step = step

func set_last_step(step : Vector2):
	last_step = step

func move():
	position += next_step
	moved.emit(Vector2(last_step))
	last_step = Vector2(next_step)
	
func bounce():
	position -= last_step
	bounced.emit(Vector2(next_step))
	next_step = Vector2(last_step)

func enable_entity_monitoring():
	$EntityCollider.monitoring = true

func _on_tile_map_collider_entered_unstable(_coords):
	#if new stability is 1, then it used to be stable
	if unstable_counter == 1:
		stability_changed.emit(self, 1)

func _on_tile_map_collider_exited_unstable(_coords):
	#if new stability is 0, then it used to be unstable
	if unstable_counter == 0:
		stability_changed.emit(self, 0)

func _on_entity_collider_area_entered(area):
	if area.get_parent() is Segment:
		hit_self.emit(self, area.get_parent())
