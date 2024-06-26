extends StateMachineState

@export var snake : Snake

const TIMER_LENGTH : float = 0.5
var timer : float

# Called when the state machine enters this state.
func on_enter():
	timer = TIMER_LENGTH


# Called every frame when this state is active.
func on_process(delta):
	if snake.unstable_count >= snake.num_segments:
		change_state("Falling")
	if timer <= 0:
		change_state("Move")
	timer -= delta


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	if event.is_action_pressed("Left"):
		snake.set_dir(Snake.DIRECTION.LEFT)
	if event.is_action_pressed("Right"):
		snake.set_dir(Snake.DIRECTION.RIGHT)
	if event.is_action_pressed("Up"):
		snake.set_dir(Snake.DIRECTION.UP)
	if event.is_action_pressed("Down"):
		snake.set_dir(Snake.DIRECTION.DOWN)
	if event.is_action_pressed("Dash"):
		change_state("Dash")


# Called when the state machine exits this state.
func on_exit():
	pass

