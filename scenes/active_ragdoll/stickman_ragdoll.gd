extends Node2D
class_name ActiveRagdoll

@export var power := 100
@export var torque := 1000
@export var torso: RigidBody2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left"):
		torso.apply_force(Vector2.LEFT * power)
	
	var angle = torso.global_transform.get_rotation() + PI/2.
	torso.apply_torque(- angle * torque)
