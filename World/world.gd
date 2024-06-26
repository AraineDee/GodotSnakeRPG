extends Node2D

class_name World



var snake_head_chunk : Chunk
@export var snake : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Snake.burrowed.connect(WorldManager.do_burrow)
	$Snake.died.connect(WorldManager.load_burrow)


func apple_tree(segment : Segment, tile_coords : Vector2i):
	snake_head_chunk.handle_apple_tree(segment, tile_coords)


