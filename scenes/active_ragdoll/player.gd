extends Node2D
class_name Player

@export var sensitivity := 1.0
@export var power := 100
@export var torque := 1000
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
@export_group("Nodes", "_")
@export var _health_component: HealthComponent
@onready var mouse_pivot: Node2D = $Torso/MousePivot
var _walk_cycle := 0.

signal died
var is_on_floor := false
var input_dir := Vector2()
var input_jump := false
var _mouse_mode : Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _look_angle := 0.0
var ragdoll_parts: Array[RigidBody2D] = []

func _ready() -> void:
	_health_component.death.connect(func():died.emit())
	ragdoll_parts = [
		head,
		torso,
		r_leg_upper,
		r_leg_lower,
		l_leg_upper,
		l_leg_lower,
		r_arm_fore,
		r_arm_upper,
		l_arm_fore,
		l_arm_upper
	]
	
	var bodies: Array[RigidBody2D] = []
	for child in get_children():
		if child is not RigidBody2D: continue
		bodies.append(child)
	for body in bodies:
		for part in bodies:
			if body == part: continue
			body.add_collision_exception_with(part)
	

func _ik_two_seg(
	root_pos:Vector2, 
	upper:TargetAngleRigidBody2D, 
	joint:Vector2, 
	lower:TargetAngleRigidBody2D, 
	target_point:Vector2
) -> void:
	var upper_length := root_pos.distance_to(joint)
	#var fore_length := joint.distance_to(target_point)
	var fore_length = upper_length
	
	var target_distance := root_pos.distance_to(target_point)
	
	target_distance = clamp(
		target_distance, 
		abs(upper_length - fore_length) + 0.001,
		upper_length + fore_length - 0.001
	)
	var target_angle := (target_point - root_pos).angle()
	
	var upper_offset := acos(clamp(
		(upper_length * upper_length + target_distance * target_distance - fore_length * fore_length) /\
		(2.0 * upper_length * target_distance),
		-1.0,
		1.0
	))
	
	
	var shoulder_angle := target_angle - upper_offset
	var new_elbow = root_pos + Vector2.from_angle(shoulder_angle) * upper_length
	var forearm_angle := (target_point - new_elbow).angle()
	upper.target_angle = shoulder_angle - PI/2.
	lower.target_angle = forearm_angle - PI/2.

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_on_floor = false
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		#var point = state.get_contact_local_position(i)
		if normal.dot(Vector2.UP) > 0.999:
			is_on_floor = true

func _physics_process(delta: float) -> void:
	_handle_input()
	if not multiplayer.is_server(): return
	_process_movement(input_dir, input_jump, _look_angle, delta)

func _handle_input():
	if not is_multiplayer_authority(): 
		#_gun.position = Vector2.RIGHT.rotated(_gun_angle) * gun_radius
		return # only client controls client player
	
	
	var dir := Input.get_vector("left", "right", "down", "up")
	var jump = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")
	var look_angle = mouse_pivot.position.angle()
	
	if multiplayer.is_server():
		input_dir = dir
		input_jump = jump
	else:
		submit_input.rpc(dir, jump, look_angle)
@rpc("any_peer", "unreliable")
## Sending input from client to server
func submit_input(dir:Vector2, jump:bool, look_angle: float) -> void:
	input_dir = dir
	input_jump = jump
	_look_angle = look_angle

#region Syncing state
@rpc("any_peer", "unreliable")
## Server processing and then sending back
func sync_state(state:Array) -> void:
	if multiplayer.is_server(): return # don't overwrite server's local player
	for i in range(min(state.size(), ragdoll_parts.size())):
		var body := ragdoll_parts[i]
		body.global_position = state[i]["pos"]
		body.global_rotation = state[i]["rot"]
		body.linear_velocity = state[i]["vel"]
		body.angular_velocity = state[i]["ang_vel"]
func get_state() -> Array:
	var state := []
	for body in ragdoll_parts:
		state.append({
			"pos": body.global_position,
			"rot": body.global_rotation,
			"vel": body.linear_velocity,
			"ang_vel": body.angular_velocity,
		})
	return state
#endregion
func _process_movement(dir:Vector2, jump:bool, look_angle:float, delta:float) -> void:
	mouse_pivot.position = Vector2.RIGHT.rotated(look_angle) * 200
	_ik_two_seg(r_shoulder.global_position, r_arm_upper, r_elbow.global_position, r_arm_fore, mouse_pivot.global_position)
	var can_jump := true
	if not is_on_floor:
		can_jump = false

	if can_jump and (jump):
		torso.apply_central_impulse(Vector2.UP * 2000.)
	if dir.x < 0:
		torso.apply_force(Vector2.LEFT * power)
		_walk_cycle += delta * 5.
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(cos(_walk_cycle)*100. , 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(sin(_walk_cycle)*100. , 500))
	elif dir.x > 0:
		torso.apply_force(Vector2.RIGHT * power)
		_walk_cycle += delta * 5.
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(-cos(_walk_cycle)*100. , 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(-sin(_walk_cycle)*100. , 500))
	else:
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(0, 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(0, 500))
	
	if multiplayer.is_server():
		sync_state.rpc(get_state())

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("l_click"):
		_mouse_mode = Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("esc"):
		_mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		var dir = mouse_pivot.position + event.relative * 2.
		_look_angle = dir.normalized().angle()


func damage(atk:Attack):
	_health_component.damage(atk)
