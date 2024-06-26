extends StateMachineState

@export var snake : Snake

# Called when the state machine enters this state.
func on_enter():
	do_unburrow.call_deferred()

#this is a seperate func cuz needs to be called deffered
func do_unburrow():
	snake.add_segment()
	snake.segments[0].position = WorldManager.get_burrow_pos()

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

