extends StateMachineState

@export var snake : Snake

# Called when the state machine enters this state.
func on_enter():
	WorldManager.do_burrow()


# Called every frame when this state is active.
func on_process(_delta):
	pass


# Called every physics frame when this state is active.
func on_physics_process(_delta):
	pass


# Called when there is an input event while this state is active.
func on_input(_event: InputEvent):
	pass


# Called when the state machine exits this state.
func on_exit():
	pass

