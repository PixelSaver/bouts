extends RigidBody2D
class_name TargetAngleRigidBody2D

@export var target_angle := 0.0
@export var power := 1.0
@export var damping := 10.0

func _physics_process(_delta: float) -> void:
	var diff = angle_difference(self.global_rotation, target_angle)
	var torque: float = diff * power - angular_velocity * damping
	self.apply_torque(torque)
