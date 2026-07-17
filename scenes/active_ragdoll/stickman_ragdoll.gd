extends Node2D
class_name ActiveRagdoll

@export var sensitivity := 1.0
@export var power := 100
@export var torque := 1000
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
@onready var mouse_pivot: Node2D = $Torso/MousePivot
var _walk_cycle := 0.

func _ready() -> void:
	var bodies: Array[RigidBody2D] = []
	for child in get_children():
		if child is not RigidBody2D: continue
		bodies.append(child)
	for body in bodies:
		for part in bodies:
			if body == part: continue
			body.add_collision_exception_with(part)
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		torso.apply_central_impulse(Vector2.UP * 2000.)
	if Input.is_action_pressed("left"):
		torso.apply_force(Vector2.LEFT * power)
		_walk_cycle += delta * 5.
		#r_leg.target_angle = sin(_walk_cycle)*.5 
		#l_leg.target_angle = cos(_walk_cycle)*.5 
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(cos(_walk_cycle)*100. , 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(sin(_walk_cycle)*100. , 500))
	elif Input.is_action_pressed("right"):
		torso.apply_force(Vector2.RIGHT * power)
		_walk_cycle += delta * 5.
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(-cos(_walk_cycle)*100. , 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(-sin(_walk_cycle)*100. , 500))
		#r_leg.target_angle = -sin(_walk_cycle)*.5 
		#l_leg.target_angle = -cos(_walk_cycle)*.5 
	else:
		#r_leg.target_angle = 0.
		#l_leg.target_angle = 0.
		_ik_two_seg(l_pelvis.position, l_leg_upper, l_knee.position, l_leg_lower, Vector2(0, 500))
		_ik_two_seg(r_pelvis.position, r_leg_upper, r_knee.position, r_leg_lower, Vector2(0, 500))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#var pos = torso.to_local(get_global_mouse_position())
		#var dir = pos.normalized()
		var dir = mouse_pivot.position + event.relative * 2.
		dir = dir.normalized()
		mouse_pivot.position = dir * 200
		_ik_two_seg(r_shoulder.global_position, r_arm_upper, r_elbow.global_position, r_arm_fore, mouse_pivot.global_position)
		#_ik_arm(l_shoulder.global_position, l_arm_upper, l_elbow.global_position, l_arm_fore, mouse_pivot.global_position)
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
