extends Node2D
class_name Player

@export var test_weapon: WeaponManager.WeaponType
@export var sensitivity := 1.0
@export var power := 100
@export var torque := 1000
@export var sync_rate := 30
@export_group("Ragdoll Pieces")
@export var head: TargetAngleRigidBody2D
@export var torso: RigidBody2D

@export var r_pelvis: PinJoint2D
@export var r_leg_upper: TargetAngleRigidBody2D
@export var r_knee: PinJoint2D
@export var r_leg_lower: TargetAngleRigidBody2D

@export var l_pelvis: PinJoint2D
@export var l_leg_upper: TargetAngleRigidBody2D
@export var l_knee: PinJoint2D
@export var l_leg_lower: TargetAngleRigidBody2D

@export var r_shoulder: PinJoint2D
@export var r_arm_fore: TargetAngleRigidBody2D
@export var r_elbow: PinJoint2D
@export var r_arm_upper: TargetAngleRigidBody2D

@export var l_shoulder: PinJoint2D
@export var l_arm_fore: TargetAngleRigidBody2D
@export var l_elbow: PinJoint2D
@export var l_arm_upper: TargetAngleRigidBody2D
@export_group("Hand stuff")
@export var r_hand_marker: Marker2D
@export var r_hand_groove_joint: GrooveJoint2D
@export var r_hand_pin_joint: PinJoint2D
@export_group("Nodes", "_")
@export var _health_component: HealthComponent
@export var _win_number_label: WinNumberLabel
@export var weapon: Weapon
var mouse_motion := Vector2.ZERO
var _walk_cycle := 0.
var _disabled := DisableMode.FREE
enum DisableMode {
	## Active ragdoll, physics, input, and state syncing
	FREE,
	## Passive ragdoll, physics, input, and state syncing
	PHYSICS,
	## No ragdoll, no physics, no input, and state syncing
	FROZEN,
	## No ragdoll, no physics, no input, and no state syncing
	NOTHING,
}

signal died
## Flag to make sure only jump once per contact
var _jump_armed := true
var _jump_buffer := 0.0
var max_jump_buffer := 0.2
var can_jump := false
var _skill_countdown := 0.0
var input_dir := Vector2()
var input_jump := false
var input_skill := false
var input_motion := Vector2.ZERO
var _mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var ragdoll_parts: Array[TargetAngleRigidBody2D] = []
var is_syncing_state := true
var _sync_clock := 0.0
var _game_info: GameInfo


func _ready() -> void:
	GDSync.expose_func(submit_input)
	GDSync.expose_func(sync_state)
	if OS.is_debug_build() and test_weapon:
		self.bind_weapon(test_weapon)

	_health_component.death.connect(
		func():
			died.emit(),
	)

	var bodies: Array[TargetAngleRigidBody2D] = []
	for child in get_children():
		if child is not TargetAngleRigidBody2D:
			continue
		bodies.append(child)
	for body in bodies:
		weapon.add_collision_exception_with(body)
		for part in bodies:
			if body == part:
				continue
			body.add_collision_exception_with(part)
	ragdoll_parts = bodies

#region Ragdoll
func set_disable(disabled: DisableMode) -> void:
	#Log.pr("Setting player state: %s" % DisableMode.keys()[disabled])
	_disabled = disabled
	match disabled:
		DisableMode.FREE:
			for part in ragdoll_parts:
				part.disabled = false
				part.freeze = false
			is_syncing_state = true
		DisableMode.PHYSICS:
			for part in ragdoll_parts:
				part.disabled = true
				part.freeze = false
			is_syncing_state = true
		DisableMode.FROZEN:
			for part in ragdoll_parts:
				part.disabled = true
				part.freeze = true
			is_syncing_state = true
		DisableMode.NOTHING:
			for part in ragdoll_parts:
				part.disabled = true
				part.freeze = true
			is_syncing_state = false


func get_cam_follow_node() -> Node2D:
	return torso


func begin_round(game_info: GameInfo) -> void:
	_game_info = game_info
	var wins = game_info.get_wins(GDSync.get_gdsync_owner(self))
	_win_number_label.flash_wins(wins)
	$DebugLabel.text = str(GDSync.get_gdsync_owner(self))
	for body in ragdoll_parts:
		GDSync.set_gdsync_owner(body, GDSync.get_host())
		GDSync.set_gdsync_owner(body, GDSync.get_host())
		#GDSync.set_gdsync_owner(body, GDSync.get_gdsync_owner(self))


func _ik_two_seg(
	root_pos: Vector2,
	upper: TargetAngleRigidBody2D,
	joint: Vector2,
	lower: TargetAngleRigidBody2D,
	target_point: Vector2,
	#print_debug:bool=false
) -> void:
	var upper_length := root_pos.distance_to(joint)
	#var fore_length := joint.distance_to(target_point)
	var fore_length = upper_length

	var to_target = target_point - root_pos
	var target_distance := root_pos.distance_to(target_point)

	var min_distance := upper_length * 0.5
	if target_distance < min_distance:
		to_target = to_target.normalized() if target_distance > 0.0001 else Vector2.RIGHT
		to_target *= min_distance
		target_distance = min_distance
	#target_distance = clamp(
	#target_distance,
	#abs(upper_length - fore_length) + .001,
	#upper_length + fore_length - .001
	#)
	var clamped_target = root_pos + to_target
	var target_angle := to_target.angle()

	var upper_offset := acos(
		clamp(
			(
				upper_length * upper_length + target_distance * target_distance
				- fore_length * fore_length
			) / \
					(2.0 * upper_length * target_distance),
			-1.0,
			1.0,
		)
	)

	var shoulder_angle := target_angle - upper_offset
	var new_elbow = root_pos + Vector2.from_angle(shoulder_angle) * upper_length
	var forearm_angle := (clamped_target - new_elbow).angle()
	upper.target_angle = shoulder_angle - PI / 2.
	lower.target_angle = forearm_angle - PI / 2.


func _physics_process(delta: float) -> void:
	if not multiplayer.multiplayer_peer:
		return
	_handle_input()
	if not GDSync.is_host():
		return
	_update_can_jump()
	_process_movement(input_dir, input_jump, input_motion, delta)
#endregion
#region Input
func _update_can_jump() -> void:
	can_jump = false
	for part in ragdoll_parts:
		can_jump = can_jump or part.is_touching_ground
	if not can_jump:
		_jump_armed = true
	#if is_multiplayer_authority() and GDSync.is_host():
	#print("Can jump? %s" % can_jump)


func _handle_input():
	#if not multiplayer.multiplayer_peer:
	#return
	if not GDSync.is_gdsync_owner(self):
		#_gun.position = Vector2.RIGHT.rotated(_gun_angle) * gun_radius
		return # only client controls client player
	if _disabled == DisableMode.FROZEN or _disabled == DisableMode.NOTHING:
		return

	var dir := Input.get_vector("left", "right", "down", "up")
	var jump = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")
	var skill = Input.is_action_just_pressed("r_click") or Input.is_action_just_pressed("shift")
	var motion = mouse_motion
	mouse_motion = Vector2.ZERO

	if is_syncing_state == false:
		return

	if GDSync.is_host():
		input_dir = dir
		input_jump = jump
		input_motion = motion
		input_skill = skill
	elif _game_info != null:
		GDSync.call_func(submit_input, dir, jump, skill, motion)
	else:
		Log.err("Game info is null for player!")


#@rpc("any_peer", "unreliable")
## Sending input from client to server
func submit_input(dir: Vector2, jump: bool, skill: bool, _mouse_motion: Vector2) -> void:
	if not GDSync.is_host():
		return
	input_dir = dir
	input_jump = jump
	input_skill = skill
	input_motion = _mouse_motion
#endregion
#region Syncing state

## Server processing and then sending back
func sync_state(state: Array) -> void:
	if GDSync.is_host():
		return # don't overwrite server's local player
	for i in range(min(state.size() - 1, ragdoll_parts.size())):
		var body := ragdoll_parts[i]
		RigidBody2DState.set_state(state[i], body)
	RigidBody2DState.set_state(state[state.size() - 1], weapon)


func get_state() -> Array:
	var state := []
	for body in ragdoll_parts:
		state.append(RigidBody2DState.get_state(body))
	state.append(RigidBody2DState.get_state(weapon))
	return state
#endregion
#region Movement and input
func _process_movement(dir: Vector2, jump: bool, _mouse_motion: Vector2, delta: float) -> void:
	_jump_buffer -= delta
	_skill_countdown -= delta
	var target = r_hand_marker.global_position + _mouse_motion
	#mouse_pivot.global_position = look_pos
	_ik_two_seg(
		r_shoulder.global_position,
		r_arm_upper,
		r_elbow.global_position,
		r_arm_fore,
		target,
	)

	if weapon != null and input_skill and _skill_countdown < 0.:
		input_skill = false
		_skill_countdown = weapon.get_skill_cooldown()
		weapon.apply_skill(self)

	if can_jump and _jump_armed and (jump or _jump_buffer > 0.):
		_jump_armed = false
		torso.apply_central_impulse(Vector2.UP * 1300.)
	elif jump:
		_jump_buffer = max_jump_buffer
	if dir.x < 0:
		torso.apply_force(Vector2.LEFT * power)
		_walk_cycle += delta * 5.
		_ik_two_seg(
			l_pelvis.position,
			l_leg_upper,
			l_knee.position,
			l_leg_lower,
			Vector2(cos(_walk_cycle) * 100., 500),
		)
		_ik_two_seg(
			r_pelvis.position,
			r_leg_upper,
			r_knee.position,
			r_leg_lower,
			Vector2(sin(_walk_cycle) * 100., 500),
		)
	elif dir.x > 0:
		torso.apply_force(Vector2.RIGHT * power)
		_walk_cycle += delta * 5.
		_ik_two_seg(
			l_pelvis.position,
			l_leg_upper,
			l_knee.position,
			l_leg_lower,
			Vector2(-cos(_walk_cycle) * 100., 500),
		)
		_ik_two_seg(
			r_pelvis.position,
			r_leg_upper,
			r_knee.position,
			r_leg_lower,
			Vector2(-sin(_walk_cycle) * 100., 500),
		)
	else:
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(0, 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(0, 500))

	#var err = target.distance_to(r_hand_marker.global_position)
	#print("Hand error: %s" % err)
	if is_syncing_state == false:
		return
	if GDSync.is_host() and _sync_clock > 60. / float(sync_rate):
		_sync_clock = 0.
		#sync_state.rpc(get_state())z
		GDSync.call_func(sync_state, get_state())
	_sync_clock += delta


func _input(event: InputEvent) -> void:
	if _disabled == DisableMode.FROZEN or _disabled == DisableMode.NOTHING:
		return
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		mouse_motion += event.relative * sensitivity

#endregion

func set_color(col: Color) -> void:
	for part in ragdoll_parts:
		part.modulate = col


func bind_weapon(wt: WeaponManager.WeaponType):
	var w = WeaponManager.get_weapon(wt).instantiate() as Weapon
	self.add_child(w)
	w.player = self
	if weapon:
		weapon.queue_free()
	weapon = w
	var path = weapon.get_path()
	var bodies: Array[RigidBody2D] = []
	for part in ragdoll_parts:
		bodies.append(part)
	weapon.set_body_collision_exceptions(bodies)
	weapon.global_transform = r_hand_marker.global_transform
	r_hand_groove_joint.node_b = path
	r_hand_pin_joint.node_b = path


func damage(atk: Attack):
	_health_component.damage(atk)
	torso.apply_central_impulse(atk.knockback)


static func try_damage_player_body_part(attack: Attack, body: Node, owner_player: Player = null) -> bool:
	var par = body.get_parent()
	if body is Weapon or par is not Player:
		return false
	var player = par as Player
	if player == owner_player:
		return false
	player.damage(attack)
	return true
