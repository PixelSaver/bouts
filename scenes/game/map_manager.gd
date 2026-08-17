extends Node2D
class_name MapManager

enum MapCollection {
	DEFAULT,
	BATTLEFIELD,
	VALLEY,
	CHAINS,
	PINWHEEL,
}
var maps: Dictionary[MapCollection, PackedScene] = {
	MapCollection.DEFAULT: preload("res://scenes/game/maps/default_map.tscn"),
	MapCollection.BATTLEFIELD: preload("res://scenes/game/maps/battlefield_map.tscn"),
	MapCollection.VALLEY: preload("res://scenes/game/maps/valley_map.tscn"),
	MapCollection.CHAINS: preload("res://scenes/game/maps/chains_map.tscn"),
	MapCollection.PINWHEEL: preload("res://scenes/game/maps/pinwheel_map.tscn"),
}
var _current_map: Map


func _ready() -> void:
	pass


func clear_maps() -> void:
	for child in get_children():
		child.queue_free()


func pick_map(map: MapCollection) -> void:
	clear_maps()
	var _map = maps.get(map, MapCollection.DEFAULT).instantiate() as Map
	if not _map:
		Log.err("Map not instantiatable, map requested was idx %s" % map)
	_current_map = _map
	add_child(_map)


func get_spawn_points() -> Array[Vector2]:
	return _current_map.get_spawn_points()
