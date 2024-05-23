extends Control

@onready var WorldScene : PackedScene = load("res://World/world.tscn")

func _start_game():
	var world = WorldScene.instantiate()
	get_tree().root.add_child(world)
	queue_free()


func _on_play_button_button_down():
	_start_game()
