extends RigidBody2D
class_name TargetAngleRigidBody2D

@export var target_angle := 0.0 :
	set(val):
		var diff = angle_difference(target_angle, val)
		var max_step = max_angular_speed * get_physics_process_delta_time()
		target_angle += clampf(diff, -max_step, max_step)
@export var power := 1.0
@export var damping := 10.0
@export var max_angular_speed := 10.
@export var disabled := false
var is_touching_ground := false
var is_touching_wall := false

func _physics_process(_delta: float) -> void:
	if disabled: return
	var diff = angle_difference(self.global_rotation, target_angle)
	var torque: float = diff * power - angular_velocity * damping
	self.apply_torque(torque)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_touching_ground = false
	is_touching_wall = false
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		#var point = state.get_contact_local_position(i)
		if normal.dot(Vector2.UP) > 0.999:
			is_touching_ground = true
		if normal.dot(Vector2.RIGHT) > 0.999 or normal.dot(Vector2.LEFT) > 0.999:
			is_touching_wall = true
