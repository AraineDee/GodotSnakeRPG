extends TileMap

class_name Chunk

const MAX_CHUNK_LIFE : float = 1

@export var chunk_id : Vector2i

@onready var chunk_area : Area2D = $ChunkArea

signal snake_entered(id : Vector2i)
signal snake_in_chunk(id : Vector2i)
signal snake_exited(id : Vector2i)
var segment_count : int = 0 #the amount of segments in this chunk

var chunk_life : float = MAX_CHUNK_LIFE #the amount of seconds the chunk has to live before being unloaded

func _process(delta):
	if segment_count > 0:
		snake_in_chunk.emit(chunk_id)
	
	if segment_count == 0 and chunk_life <= 0:
		queue_free()
	
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


func erase_pickup(coords : Vector2i):
	erase_cell(2, coords)


func _on_chunk_area_area_entered(area):
	if area.get_parent() is Segment:
		_on_segment_entry()


func _on_chunk_area_area_exited(area):
	if area.get_parent() is Segment:
		_on_segment_exit()
