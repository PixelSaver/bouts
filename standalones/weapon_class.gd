extends RigidBody2D
class_name Weapon

@export_group("Weapon Info", "weapon_")
@export var weapon_name: String
@export var weapon_damage: float = 1.0
@export var weapon_skill_cooldown: float = 5.0
@export var weapon_description := "Lorem Ipsum SAVEME PLEASE"
@export var player: Player
var target_state: Array = []


func _get_attack() -> Attack:
	var atk = Attack.new()
	atk.damage = weapon_damage
	return atk


func get_skill_cooldown() -> float:
	return weapon_skill_cooldown


func apply_skill(_player: Player = player) -> void:
	pass


func set_body_collision_exceptions(_bodies: Array[RigidBody2D]) -> void:
	pass


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
