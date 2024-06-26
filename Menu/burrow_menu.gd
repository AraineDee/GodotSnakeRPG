extends Control


func _on_exit_button_button_down():
	WorldManager.start_game.call_deferred()
