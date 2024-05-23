extends StateMachineState

@export var snake : Snake

const TIMER_LENGTH : float = 0.5
var timer : float

# Called when the state machine enters this state.
func on_enter():
	timer = TIMER_LENGTH


# Called every frame when this state is active.
func on_process(delta):
	if timer <= 0:
		change_state("Idle")
	timer -= delta


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	if event.is_action_pressed("Left"):
		snake.turn_left()
	if event.is_action_pressed("Right"):
		snake.turn_right()


# Called when the state machine exits this state.
func on_exit():
	pass

