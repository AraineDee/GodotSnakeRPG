extends Control

func _on_play_button_button_down():
	WorldManager.load_burrow.call_deferred()
