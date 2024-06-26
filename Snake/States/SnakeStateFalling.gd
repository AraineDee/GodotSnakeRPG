extends StateMachineState

@export var snake : Snake

const TIMER_LENGTH : float = 0.5
var timer : float

var chunk : Chunk
var head_coords : Vector2i

# Called when the state machine enters this state.
func on_enter():
	timer = TIMER_LENGTH
	chunk = snake.get_parent().snake_head_chunk
	head_coords = chunk.get_local_coords(snake.segments[0].global_position)


# Called every frame when this state is active.
func on_process(delta):
	if timer <= 0:
		pass
	
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

