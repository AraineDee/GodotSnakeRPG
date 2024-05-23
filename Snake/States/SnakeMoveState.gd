extends StateMachineState

@export var snake : Snake

# Called when the state machine enters this state.
func on_enter():
	#do move
	snake.segments[0].set_next_step(snake.get_next_step())
	snake.move.emit()
	snake.last_dir = snake.dir


# Called every frame when this state is active.
func on_process(_delta):
	#change state to idle
	change_state("Idle")


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

