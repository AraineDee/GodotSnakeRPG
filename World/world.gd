extends Node2D


@onready var BurrowMenuScene : PackedScene = preload("res://Menu/burrow_menu.tscn")

var chunk_position_scaling : int = 2048

var snake_head_chunk : Chunk
@export var snake : Node2D

var chunk_offset : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	load_chunk()
	$Snake.burrowed.connect(handle_burrow)

func handle_burrow():
	chunk_offset = Vector2i(snake_head_chunk.chunk_id)
	unload_all_chunks()
	open_burrow_menu.call_deferred()

func open_burrow_menu():
	var menu = BurrowMenuScene.instantiate()
	add_child(menu)

func unload_all_chunks():
	for chunk in get_tree().get_nodes_in_group("Chunk"):
		chunk.chunk_life = 0

func handle_unburrow():
	snake.unburrow()
	load_chunk()

func get_chunk_scene(_chunk_id : Vector2i) -> PackedScene:
	return load("res://World/Chunk/Chunks/TestChunk.tscn")

func chunk_is_loaded(chunk_id : Vector2i) -> Chunk:
	for chunk in get_tree().get_nodes_in_group("Chunk"):
		if chunk.chunk_id == chunk_id:
			return chunk
	return null

func load_chunk(chunk_id : Vector2i = Vector2i(), use_id_as_pos : bool = true) -> Chunk:
	chunk_id = chunk_id + chunk_offset
	var chunk = chunk_is_loaded(chunk_id)
	if chunk != null:
		chunk.reset_chunk_life()
		return
	
	#instantiate and isolate chunk
	var chunk_parent = get_chunk_scene(chunk_id).instantiate()
	chunk = chunk_parent.get_child(0) as Chunk
	chunk_parent.remove_child(chunk)
	add_child(chunk)
	#print(chunk_parent.name)
	chunk_parent.queue_free()
	
	chunk.chunk_id = chunk_id
	
	#connect signals
	chunk.snake_in_chunk.connect(chunk_has_snake)
	chunk.snake_entered.connect(snake_entered_chunk)
	
	if use_id_as_pos:
		chunk.position = chunk_id * chunk_position_scaling
	
	return chunk

func load_chunk_at_pos(chunk_id : Vector2i, pos : Vector2i) -> Chunk:
	var chunk = load_chunk(chunk_id, false)
	chunk.position = pos * chunk_position_scaling
	
	return chunk

func load_adjacent_chunks(chunk_id : Vector2i) -> Array:
	var new_chunks = []
	var chunk_ids = get_adjacent_chunks(chunk_id)
	
	for id in chunk_ids:
		new_chunks.append(load_chunk(id))
	
	return new_chunks

func get_adjacent_chunks(chunk_id : Vector2i) -> Array:
	return [
		chunk_id + Vector2i.UP,
		chunk_id + Vector2i.DOWN,
		chunk_id + Vector2i.LEFT,
		chunk_id + Vector2i.RIGHT
	]

func chunk_has_snake(chunk_id : Vector2i):
	load_chunk(chunk_id)
	load_adjacent_chunks(chunk_id)

func snake_entered_chunk(chunk_id : Vector2i):
	snake_head_chunk = chunk_is_loaded(chunk_id)
