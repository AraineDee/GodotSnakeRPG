extends StateMachineState

@export var snake : Snake

var chunk : Chunk
var coords : Vector2i

# Called when the state machine enters this state.
func on_enter():
	snake.desired_segments = snake.num_segments
	while snake.num_segments > 1:
		snake.remove_segment(snake.num_segments - 1)
	snake.segments[0].position = chunk.get_global_pos(coords)


# Called every frame when this state is active.
func on_process(_delta):
	pass


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(event: InputEvent):
	var dir_was_set = false
	if event.is_action_pressed("Left"):
		snake.set_dir(Snake.DIRECTION.LEFT)
		dir_was_set = true
	if event.is_action_pressed("Right"):
		snake.set_dir(Snake.DIRECTION.RIGHT)
		dir_was_set = true
	if event.is_action_pressed("Up"):
		snake.set_dir(Snake.DIRECTION.UP)
		dir_was_set = true
	if event.is_action_pressed("Down"):
		snake.set_dir(Snake.DIRECTION.DOWN)
		dir_was_set = true
	
	if dir_was_set:
		change_state("UnBurrowing")


# Called when the state machine exits this state.
func on_exit():
	pass

