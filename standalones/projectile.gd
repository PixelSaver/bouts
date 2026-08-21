extends RigidBody2D
class_name Projectile

@export var hit_cooldown := 0.3
var attack: Attack
var owner_id: int = -1
var _hit_cooldown := 0.


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


class ProjectileState extends Resource:
	enum StateType {
		POS,
		ROT,
		LIN_VEL,
		ANG_VEL,
	}


	static func get_state(body: Projectile) -> Array:
		var out: Array = []
		out.append(body.global_position)
		out.append(body.global_rotation)
		out.append(body.linear_velocity)
		out.append(body.angular_velocity)
		return out


	static func set_state(state_array: Array, body: Projectile) -> void:
		body.global_position = state_array[0]
		body.global_rotation = state_array[1]
		body.linear_velocity = state_array[2]
		body.angular_velocity = state_array[3]
