extends Control

func set_state_label(string : String):
	$StateLabel.text = string

func _on_exit_button_down():
	get_tree().quit()
