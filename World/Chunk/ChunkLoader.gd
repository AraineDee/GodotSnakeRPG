extends Node

class_name ChunkLoader

@onready var world : World = get_parent()

@onready var chunk_offset : Vector2i = SaveManager.chunk_offset
var chunk_position_scaling : int = 1280

@onready var EdgeChunk_Scene : PackedScene = preload("res://World/Chunk/Chunks/EdgeChunk.tscn")
var chunk_scenes : Dictionary #chunk_id : chunk_scene

var loaded_chunks : Array[Chunk] #currently instanced chunks
var primary_chunks : Array[Chunk] #chunks with snake segments in them

var chunk_load_queue : Array[Vector2i] #list of chunks to load

func _ready():
	world.snake_head_chunk = _load_chunk(SaveManager.chunk_offset)

func submit_chunk_ticket(chunk_id : Vector2i):
	if chunk_id in chunk_load_queue:
		return
	chunk_load_queue.append(chunk_id)


func _process(_delta):
	for chunk in primary_chunks:
		submit_chunk_ticket(chunk.chunk_id)
		for adj_chunk_id in _get_adjacent_chunks(chunk.chunk_id):
			submit_chunk_ticket(adj_chunk_id)
	
	while chunk_load_queue.size() > 0:
		_load_chunk(chunk_load_queue.pop_front())
	

func _get_adjacent_chunks(chunk_id : Vector2i) -> Array[Vector2i]:
	return [
		chunk_id + Vector2i.UP,
		chunk_id + Vector2i.DOWN,
		chunk_id + Vector2i.LEFT,
		chunk_id + Vector2i.RIGHT
	]

func _get_chunk_filename(chunk_id : Vector2i) -> String:
	return "res://World/Chunk/Chunks/Chunk_%d_%d.tscn" % [chunk_id.x, chunk_id.y]

func _get_chunk_scene(chunk_id : Vector2i) -> PackedScene:
	if chunk_scenes.has(chunk_id):
		return chunk_scenes[chunk_id]
	var chunk_file = _get_chunk_filename(chunk_id)
	if FileAccess.file_exists(chunk_file):
		return load(chunk_file)

	return EdgeChunk_Scene

func _chunk_is_loaded(chunk_id : Vector2i) -> Chunk:
	for chunk in loaded_chunks:
		if chunk.chunk_id == chunk_id:
			return chunk
	return null

func _load_chunk(chunk_id : Vector2i = Vector2i(), set_pos_to_id : bool = true) -> Chunk:
	chunk_id = chunk_id + chunk_offset
	var chunk = _chunk_is_loaded(chunk_id)
	if chunk != null:
		chunk.reset_chunk_life()
		return chunk
	
	chunk = _get_chunk_scene(chunk_id).instantiate() as Chunk
	chunk.snake_entered.connect(_on_chunk_snake_entered)
	chunk.snake_exited.connect(_on_chunk_snake_exited)
	chunk.died.connect(_on_chunk_died)
	
	chunk.chunk_id = chunk_id
	
	world.add_child.call_deferred(chunk)
	loaded_chunks.append(chunk)
	
	if set_pos_to_id:
		_set_chunk_pos(chunk, chunk_id)
	
	return chunk

func _set_chunk_pos(chunk : Chunk, pos : Vector2i):
	chunk.position = (pos-chunk_offset) * chunk_position_scaling

func _on_chunk_died(chunk):
	loaded_chunks.erase(chunk)
	chunk.queue_free()

func _on_chunk_snake_entered(chunk_id : Vector2i):
	primary_chunks.append(_chunk_is_loaded(chunk_id))
	world.snake_head_chunk = _chunk_is_loaded(chunk_id) #this might cause an error later when bouncing off edge chunks`

func _on_chunk_snake_exited(chunk_id : Vector2i):
	primary_chunks.erase(_chunk_is_loaded(chunk_id))


