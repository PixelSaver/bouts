extends Area2D
class_name WaterKillbox

@export var throw_force := 1000
@export var hit_cooldown := 0.1
var _hit_cooldown := 0.0


func _on_body_entered(body: Node2D) -> void:
	var atk = Attack.new()
	atk.damage = 3.
	atk.knockback = Vector2.UP * throw_force
	if _hit_cooldown <= 0:
		Player.try_damage_player_body_part(atk, body)
		_hit_cooldown = hit_cooldown


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
