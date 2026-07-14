extends RigidBody2D
class_name TargetAngleRigidBody2D

@export var target_angle := 0.0
@export var power := 1.0

func _physics_process(_delta: float) -> void:
	var diff = angle_difference(self.global_rotation, target_angle)
	self.apply_torque(diff * power)
