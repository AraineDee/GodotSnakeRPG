extends Control


func _on_exit_button_button_down():
	get_parent().handle_unburrow()
	queue_free()
