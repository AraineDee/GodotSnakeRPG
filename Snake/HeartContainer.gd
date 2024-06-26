extends HBoxContainer

@onready var hearts = get_children()
@onready var curr_health : int = hearts.size()

@onready var FilledHeartTexture : Texture = preload("res://art/FilledHeartSprite.png")
@onready var EmptyHeartTexture : Texture = preload("res://art/EmptyHeartSprite.png")

func update_hearts(new_health : int):
	if new_health < 0 or new_health >= hearts.size():
		return

	if new_health > curr_health:
		hearts[curr_health].texture = FilledHeartTexture
	if new_health < curr_health:
		hearts[new_health].texture = EmptyHeartTexture
	curr_health = new_health
