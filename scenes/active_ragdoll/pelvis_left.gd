extends PinJoint2D
class_name ActiveRagdollJoint2D

@export var target_angle := 0.
@export var stiffness := 10000.
@export var damping_ratio := 0.3
@export var max_torque := 5000000.
var _a: RigidBody2D
var _b: RigidBody2D

func _ready() -> void:
	_a = get_node(node_a)
	_b = get_node(node_b)

func _physics_process(delta: float) -> void:
	var angle = angle_difference(_a.global_rotation, _b.global_rotation)
	var error = angle_difference(angle, target_angle)
	var relative_velocity = _b.angular_velocity - _a.angular_velocity
	var inertia_a := _a.inertia if _a.inertia > 0.0 else 1.0
	var inertia_b := _b.inertia if _b.inertia > 0.0 else 1.0
	var effective_inertia := (inertia_a * inertia_b) / (inertia_a + inertia_b)
	var damping : float = 2.0 * damping_ratio * sqrt(stiffness * effective_inertia)
	
	
	var predicted_error = error - relative_velocity * delta
	var denom = 1.0 + damping * delta / effective_inertia + stiffness * delta * delta / effective_inertia

	var torque : float = (predicted_error * stiffness - relative_velocity * damping) / denom
	torque = clamp(torque, -max_torque, max_torque)
	_a.apply_torque(torque)
	_b.apply_torque(-torque)
	if self.is_visible_in_tree(): print("%s is at error %s" % [self.name, error])
	
