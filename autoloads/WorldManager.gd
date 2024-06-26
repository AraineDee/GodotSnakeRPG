extends Node

@onready var WorldScene : PackedScene = preload("res://World/world.tscn")
@onready var BurrowMenu : PackedScene = preload("res://Menu/burrow_menu.tscn")

func start_game():
	get_tree().change_scene_to_packed(WorldScene)

func get_world() -> World:
	return get_tree().get_first_node_in_group("World")

func do_burrow():
	#		do save management stuff
	SaveManager.chunk_offset = get_world().snake_head_chunk.chunk_id
	load_burrow()


func load_burrow():
	get_tree().change_scene_to_packed.call_deferred(BurrowMenu)


func get_burrow_pos() -> Vector2:
	return get_world().snake_head_chunk.get_burrow_pos()
