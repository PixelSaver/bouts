extends RefCounted
class_name RigidBody2DState

enum StateType {
	POS,
	ROT,
	LIN_VEL,
	ANG_VEL,
}


static func get_state(body: RigidBody2D) -> Array:
	var out: Array = []
	out.append(body.global_position)
	out.append(body.global_rotation)
	out.append(body.linear_velocity)
	out.append(body.angular_velocity)
	return out


static func set_state(state_array: Array, body: RigidBody2D) -> void:
	if body is TargetAngleRigidBody2D:
		var rigid_body_2d: TargetAngleRigidBody2D = body
		rigid_body_2d.target_state = state_array
		return
	if body is Weapon:
		var weapon: Weapon = body
		weapon.target_state = state_array
		return
	body.global_position = state_array[0]
	body.global_rotation = state_array[1]
	body.linear_velocity = state_array[2]
	body.angular_velocity = state_array[3]
