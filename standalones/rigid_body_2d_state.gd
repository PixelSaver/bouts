extends RefCounted
class_name RigidBody2DState


static func get_state(body: RigidBody2D) -> Array:
	var out: Array = []
	out.append(body.global_position)
	out.append(body.global_rotation)
	out.append(body.linear_velocity)
	out.append(body.angular_velocity)
	return out


static func set_state(state_array: Array, body: RigidBody2D) -> void:
	body.global_position = state_array[0]
	body.global_rotation = state_array[1]
	body.linear_velocity = state_array[2]
	body.angular_velocity = state_array[3]
