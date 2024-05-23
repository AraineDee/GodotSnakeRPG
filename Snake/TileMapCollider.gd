extends Area2D


signal hit_pickup(type : int, coords : Vector2i)
signal hit_wall(coords : Vector2i)
signal hit_interactable(type : int, coords : Vector2i)


signal entered_unstable(coords : Vector2i)
signal exited_unstable(coords : Vector2i)

@onready var segment = get_parent() as Segment

var pickup_RIDs := [] #these are RIDs of pickups that'll be destroyed, and should be ignored for uncollision

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


#region Collision
func _process_tilemap_collision(tilemap : Chunk, body_rid : RID):
	var collided_tile_coords = tilemap.get_coords_for_body_rid(body_rid)
	var collided_tile_layer = tilemap.get_layer_for_body_rid(body_rid)
	
	var tile_data = tilemap.get_cell_tile_data(collided_tile_layer, collided_tile_coords) as TileData
	if !tile_data is TileData:
		return
	
	match collided_tile_layer:
		0: #terrain layer
			pass
		1: #hazard layer
			_handle_hazard_collision(tilemap, tile_data, collided_tile_coords)
		2: #pickup layer
			emit_signal("hit_pickup", tile_data.get_custom_data("PickupType"), collided_tile_coords)
			tilemap.erase_pickup(collided_tile_coords)
			pickup_RIDs.append(body_rid)
		3: #interactable layer
			emit_signal("hit_interactable", tile_data.get_custom_data("InteractableType"), collided_tile_coords)
		_:
			pass

func _handle_hazard_collision(_tilemap : Chunk, tile_data : TileData, tile_coords : Vector2i):
	if tile_data.get_custom_data("Solid"):
		emit_signal("hit_wall", tile_coords)

	if tile_data.get_custom_data("Unstable"):
		segment.unstable_counter += 1
		emit_signal("entered_unstable", tile_coords)
#endregion

#region UNCOLLISION
func _process_tilemap_uncollision(tilemap : Chunk, body_rid : RID):
	if pickup_RIDs.count(body_rid) > 0:
		pickup_RIDs.erase(body_rid)
		return
	
	var collided_tile_coords = tilemap.get_coords_for_body_rid(body_rid)
	var collided_tile_layer = tilemap.get_layer_for_body_rid(body_rid)
	
	var tile_data = tilemap.get_cell_tile_data(collided_tile_layer, collided_tile_coords) as TileData
	if !tile_data is TileData:
		return
	
	match collided_tile_layer:
		0: #terrain layer
			pass
		1: #hazard layer
			_handle_hazard_uncollision(tilemap, tile_data, collided_tile_coords)
		2: #pickup layer
			pass
		3: #interactable layer
			pass
		_:
			pass

func _handle_hazard_uncollision(_tilemap : Chunk, tile_data : TileData, tile_coords : Vector2i):
	if tile_data.get_custom_data("Unstable"):
		segment.unstable_counter -= 1
		emit_signal("entered_unstable", tile_coords)

#endregion

func _on_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is Chunk:
		_process_tilemap_collision(body, body_rid)


func _on_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	if body is Chunk:
		_process_tilemap_uncollision(body, body_rid)
