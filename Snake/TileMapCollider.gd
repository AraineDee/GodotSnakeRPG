extends Area2D


signal hit_pickup(segment : Segment, type : int, coords : Vector2i)
signal hit_hazard(segment : Segment, type : int, coords : Vector2i)
signal hit_interactable(segment : Segment, type : int, coords : Vector2i)

signal left_hazard(segment : Segment, type : int, coords : Vector2i)
signal left_interactable(segment : Segment, type : int, coords : Vector2i)

@onready var segment = get_parent() as Segment

var erased_RIDs := [] #these are RIDs of things that'll be destroyed, and should be ignored for uncollision

#region Collision
func _process_tilemap_collision(tilemap : TileMap, body_rid : RID):
	var collided_tile_coords = tilemap.get_coords_for_body_rid(body_rid)
	var collided_tile_layer = tilemap.get_layer_for_body_rid(body_rid)

	var tile_data = tilemap.get_cell_tile_data(collided_tile_layer, collided_tile_coords) as TileData
	if !tile_data is TileData:
		return
	
	match collided_tile_layer:
		0: #terrain layer
			pass
		1: #hazard layer
			hit_hazard.emit(segment, tile_data.get_custom_data("HazardType"), collided_tile_coords)
		2: #interactable layer
			if tile_data.get_custom_data("InteractableType") == 2: #apple tree
				erased_RIDs.append(body_rid)
			hit_interactable.emit(segment, tile_data.get_custom_data("InteractableType"), collided_tile_coords)
		3: #pickup layer
			hit_pickup.emit(segment, tile_data.get_custom_data("PickupType"), collided_tile_coords)
			tilemap.erase_cell(3, collided_tile_coords)
			erased_RIDs.append(body_rid)
		_:
			pass
#endregion

#region UNCOLLISION
func _process_tilemap_uncollision(tilemap : TileMap, body_rid : RID):
	if erased_RIDs.count(body_rid) > 0:
		erased_RIDs.erase(body_rid)
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
			left_hazard.emit(segment, tile_data.get_custom_data("HazardType"), collided_tile_coords)
		2: #interactable layer
			left_interactable.emit(segment, tile_data.get_custom_data("InteractableType"), collided_tile_coords)
		3: #pickup layer
			pass
		_:
			pass
#endregion

func _on_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)


func _on_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		_process_tilemap_uncollision(body, body_rid)
