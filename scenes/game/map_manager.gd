extends Node2D
class_name MapManager

enum MapCollection {
	DEFAULT,
}
var maps: Dictionary[MapCollection, PackedScene] = {
	MapCollection.DEFAULT: preload("res://scenes/game/maps/default_map.tscn")
}
var _current_map: Map


func _ready() -> void:
	clear_maps()
	pick_map(MapCollection.DEFAULT)


func clear_maps() -> void:
	for child in get_children():
		child.queue_free()


func pick_map(map: MapCollection) -> void:
	var _map = maps.get(map, MapCollection.DEFAULT).instantiate() as Map
	if not _map:
		Log.err("Map not instantiatable, map requested was idx %s" % map)
	_current_map = _map
	add_child(_map)


func get_spawn_points() -> Array[Vector2]:
	return _current_map.get_spawn_points()
