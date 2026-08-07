extends Weapon
class_name Mace

@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3

var target_state: Array = []


func _ready() -> void:
	self.set_meta("is_weapon", true)
	self.body_entered.connect(_body_entered)


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	if player.is_syncing_state == false:
		return


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


func _body_entered(body: Node) -> void:
	if _hit_cooldown <= 0:
		Player.try_damage_player_body_part(_get_attack(), body)
		_hit_cooldown = hit_cooldown
