extends StateMachineState

@export var snake : Snake

# Called when the state machine enters this state.
func on_enter():
	#do bounce
	snake.dir = snake.last_dir
	snake.bounce.emit()


# Called every frame when this state is active.
func on_process(_delta):
	change_state("Dazed")


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

