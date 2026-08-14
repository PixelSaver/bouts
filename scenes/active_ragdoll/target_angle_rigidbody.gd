extends RigidBody2D
class_name TargetAngleRigidBody2D

var _target_angle := 0.0
@export var target_angle := 0.0:
	get:
		return _target_angle
	set(value):
		var diff = angle_difference(_target_angle, value)
		_target_angle += diff
@export var power := 1.0
@export var damping := 10.0
@export var max_torque := 300000.
@export var disabled := false
@export var state_lerp_speed := 3.
var is_touching_ground := false
var is_touching_wall := false

var target_state: Array = []


func set_target_state(state: Array) -> void:
	target_state = state.duplicate(true)


func _physics_process(_delta: float) -> void:
	var diff = angle_difference(self.global_rotation, target_angle)
	var damping_force = angular_velocity * damping * (1.0 + abs(diff))
	var torque = diff * power - damping_force
	#torque = clamp(torque, -max_torque, max_torque)
	apply_torque(torque)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if target_state.size() > 0:
		var target_pos: Vector2 = target_state[RigidBody2DState.StateType.POS]
		var target_rot: float = target_state[RigidBody2DState.StateType.ROT]
		var target_vel: Vector2 = target_state[RigidBody2DState.StateType.LIN_VEL]
		var target_ang_vel: float = target_state[RigidBody2DState.StateType.ANG_VEL]

		var pos_error = target_pos - state.transform.origin
		var rot_error = angle_difference(state.transform.get_rotation(), target_rot)

		const POS_GAIN := 15.0
		const ROT_GAIN := 15.0

		var alpha = 1.0 - exp(-12. * get_physics_process_delta_time())

		state.linear_velocity = state.linear_velocity.lerp(target_vel + pos_error * POS_GAIN, alpha)

		state.angular_velocity = lerp(
			state.angular_velocity,
			target_ang_vel + rot_error * ROT_GAIN,
			alpha,
		)

	# Contact detection
	is_touching_ground = false
	is_touching_wall = false

	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)

		if normal.dot(Vector2.UP) > 0.999:
			is_touching_ground = true

		if normal.dot(Vector2.RIGHT) > 0.999 or normal.dot(Vector2.LEFT) > 0.999:
			is_touching_wall = true
