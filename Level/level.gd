extends TileMap

@export var EndScreenScene : PackedScene

@export var keys_left := 0

func _on_snake_hit_goal():
	if keys_left == 0:
		_game_end(1)

func _on_snake_died():
	_game_end(-1)

func _on_snake_got_key():
	keys_left -= 1

func _game_end(state : int):
	var world = get_parent()
	var end_scene = EndScreenScene.instantiate()
	get_tree().root.add_child(end_scene)
	if state == 1:
		end_scene.set_state_label("You Win")
	if state == -1:
		end_scene.set_state_label("You Lose")
	world.queue_free()
	
	

func despawn_pickup(pickup_coords : Vector2i):
	erase_cell(1, pickup_coords)
