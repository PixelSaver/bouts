extends RigidBody2D
class_name Projectile

@export var hit_cooldown := 0.3
var attack: Attack
var owner_id: int = -1
var _hit_cooldown := 0.


func _ready() -> void:
	GDSync.expose_func(receive_state)


func process_projectile_movement(delta: float) -> void:
	_hit_cooldown -= delta
	if _hit_cooldown <= 0.:
		var collided_bodies: Array[Node2D] = []
		for col in self.get_colliding_bodies():
			collided_bodies.append(col)

		for col in collided_bodies:
			if not Player.is_collider_owner_id_same(col, owner_id):
				continue
			if Player.try_damage_player_body_part(_get_attack(), col):
				_hit_cooldown = hit_cooldown
				break


func _get_attack() -> Attack:
	return attack


func receive_state(arr: Array) -> void:
	ProjectileState.set_state(arr, self)
