extends Node2D
class_name ActiveRagdoll

@export var sensitivity := 1.0
@export var power := 100
@export var torque := 1000
@export var head: TargetAngleRigidBody2D
@export var torso: RigidBody2D
@export var r_leg: TargetAngleRigidBody2D
@export var l_leg: TargetAngleRigidBody2D
@export var r_arm: TargetAngleRigidBody2D
@export var l_arm: TargetAngleRigidBody2D
@onready var mouse_pivot: Node2D = $Torso/MousePivot
var _walk_cycle := 0.

func _ready() -> void:
	head.add_collision_exception_with(r_arm)
	head.add_collision_exception_with(l_arm)
	l_leg.add_collision_exception_with(r_leg)
	l_leg.add_collision_exception_with(l_arm)
	l_leg.add_collision_exception_with(r_arm)
	r_leg.add_collision_exception_with(r_leg)
	r_leg.add_collision_exception_with(l_arm)
	r_leg.add_collision_exception_with(r_arm)
	l_arm.add_collision_exception_with(r_leg)
	l_arm.add_collision_exception_with(l_arm)
	l_arm.add_collision_exception_with(r_arm)
	

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		torso.apply_force(Vector2.LEFT * power)
		_walk_cycle += delta * 5.
		r_leg.target_angle = sin(_walk_cycle)*.5 
		l_leg.target_angle = cos(_walk_cycle)*.5 
	elif Input.is_action_pressed("right"):
		torso.apply_force(Vector2.RIGHT * power)
		_walk_cycle += delta * 5.
		r_leg.target_angle = -sin(_walk_cycle)*.5 
		l_leg.target_angle = -cos(_walk_cycle)*.5 
	else:
		r_leg.target_angle = 0.
		l_leg.target_angle = 0.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos = torso.to_local(get_global_mouse_position())
		var dir = pos.normalized()
		r_arm.target_angle = dir.angle() - PI/2
		mouse_pivot.position = dir * 100
	
