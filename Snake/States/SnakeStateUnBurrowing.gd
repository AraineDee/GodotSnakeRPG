extends StateMachineState

@export var snake : Snake

const TIMER_LENGTH : float = 0.5
var timer : float

# Called when the state machine enters this state.
func on_enter():
	timer = TIMER_LENGTH


# Called every frame when this state is active.
func on_process(delta):
	if snake.num_segments == snake.desired_segments:
		change_state("Idle")
	if timer <= 0:
		snake.move.emit()
		snake.add_segment()
		timer = TIMER_LENGTH
	timer -= delta


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

