extends Node2D
class_name Map

@export var markers: Array[Marker2D] = []


func get_spawn_points() -> Array[Vector2]:
	return markers.map(
		func(m: Marker2D):
			return m.global_position,
	)
