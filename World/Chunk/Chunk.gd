extends Node2D

class_name Chunk

const MAX_CHUNK_LIFE : float = 5

@export var chunk_id : Vector2i

@export var chunk_area : Area2D
@export var tilemap : TileMap

signal snake_entered(id : Vector2i)
signal snake_exited(id : Vector2i)
signal died(chunk : Chunk)

var segment_count : int = 0 #the amount of segments in this chunk

var chunk_life : float = MAX_CHUNK_LIFE #the amount of seconds the chunk has to live before being unloaded

func _process(delta):
	if segment_count > 0:
		reset_chunk_life()
	
	if segment_count == 0 and chunk_life <= 0:
		died.emit(self)
	
	chunk_life -= delta

func reset_chunk_life():
	chunk_life = MAX_CHUNK_LIFE

func _on_segment_entry():
	if segment_count == 0:
		snake_entered.emit(chunk_id)
	segment_count += 1

func _on_segment_exit():
	segment_count -= 1
	if segment_count == 0:
		snake_exited.emit(chunk_id)

func get_burrow_pos() -> Vector2i:
	for coords in tilemap.get_used_cells(2):
		if tilemap.get_cell_tile_data(2, coords).get_custom_data("InteractableType") == 0:
			return tilemap.map_to_local(coords) as Vector2i
	
	assert(false, "No Burrow in this chunk")
	return Vector2i()

func get_local_coords(global_pos : Vector2) -> Vector2i:
	var local_position = global_pos - position
	return tilemap.local_to_map(local_position)

func get_global_pos(local_coords : Vector2i) -> Vector2:
	var local_position = tilemap.map_to_local(local_coords)
	return position + local_position

func handle_apple_tree(segment : Segment, tile_coords : Vector2i):
	tilemap.erase_cell(2, tile_coords)
	tilemap.set_cell(1, tile_coords, 1, Vector2i(1, 1), 0)
	var segment_coords = get_local_coords(segment.global_position)
	var segment_offset = tile_coords - segment_coords
	tilemap.set_cell(3, segment_coords + 2 * segment_offset, 1, Vector2i(2, 2), 0)


func erase_pickup(coords : Vector2i):
	tilemap.erase_cell(2, coords)


func _on_chunk_area_area_entered(area):
	if area.get_parent() is Segment:
		_on_segment_entry()


func _on_chunk_area_area_exited(area):
	if area.get_parent() is Segment:
		_on_segment_exit()
