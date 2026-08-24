extends RigidBody2D
class_name PlayerShield

@export var col: CollisionShape2D
@export var tex: TextureRect


func set_shield_scale(s: float) -> void:
	col.scale = Vector2.ONE * s
	tex.scale = Vector2.ONE * s
