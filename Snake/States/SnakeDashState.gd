extends StateMachineState

@export var snake : Snake

const TIMER_LENGTH : float = 0.1
var timer : float

# Called when the state machine enters this state.
func on_enter():
	timer = TIMER_LENGTH
	snake.segments[0].set_next_step(snake.get_next_step())
	snake.move.emit()
	snake.last_dir = snake.dir


# Called every frame when this state is active.
func on_process(delta):
	if timer <= 0:
		change_state("Move")
	timer -= delta


# Called every physics frame when this state is active.
func on_physics_process(delta):
	pass


# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

