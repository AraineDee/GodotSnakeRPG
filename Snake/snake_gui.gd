extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_parent().took_damage.connect($HeartContainer.update_hearts)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
