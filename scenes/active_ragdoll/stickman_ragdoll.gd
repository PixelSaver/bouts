extends Node2D
class_name ActiveRagdoll

@export var power := 100
@export var torque := 1000
@export var torso: RigidBody2D
@export var r_leg: TargetAngleRigidBody2D
@export var l_leg: TargetAngleRigidBody2D
var _walk_cycle := 0.

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		torso.apply_force(Vector2.LEFT * power)
		_walk_cycle += delta * 5.
		r_leg.target_angle = sin(_walk_cycle)*.5 + PI/2
		l_leg.target_angle = cos(_walk_cycle)*.5 - PI/2
	elif Input.is_action_pressed("right"):
		torso.apply_force(Vector2.RIGHT * power)
		_walk_cycle += delta * 5.
		r_leg.target_angle = -sin(_walk_cycle)*.5 + PI/2
		l_leg.target_angle = -cos(_walk_cycle)*.5 - PI/2
	else:
		r_leg.target_angle =  PI/2
		l_leg.target_angle = -PI/2
		
	
