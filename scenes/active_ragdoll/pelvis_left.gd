extends PinJoint2D
class_name ActiveRagdollJoint2D

@export var target_angle := 0.
@export var max_angular_speed := 20.0
@export var max_torque := 4000.0
var _a: RigidBody2D
var _b: RigidBody2D

func _ready() -> void:
	_a = get_node(node_a)
	_b = get_node(node_b)

func _get_inertia(body: RigidBody2D) -> float:
	return body.inertia
func _physics_process(delta: float) -> void:
	var angle = angle_difference(_a.global_rotation, _b.global_rotation)
	var error = angle_difference(angle, target_angle)
	var relative_velocity = _b.angular_velocity - _a.angular_velocity

	var inertia_a := _get_inertia(_a)
	var inertia_b := _get_inertia(_b)
	var effective_inertia := (inertia_a * inertia_b) / (inertia_a + inertia_b)

	# velocity needed to close the error this frame, capped to a sane top speed
	var desired_velocity = clamp(error / delta, -max_angular_speed, max_angular_speed)
	var velocity_delta = desired_velocity - relative_velocity

	# torque needed to achieve that velocity change, capped to motor strength
	var torque = velocity_delta * effective_inertia / delta
	torque = clamp(torque, -max_torque, max_torque)

	_a.apply_torque(torque)
	_b.apply_torque(-torque)
