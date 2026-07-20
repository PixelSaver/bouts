extends RigidBody2D
class_name Weapon

@export_group("Weapon Info", "weapon_")
@export var weapon_name : String
@export var weapon_damage : float = 1.0
@export var weapon_description := "Lorem Ipsum SAVEME PLEASE"

func _get_attack() -> Attack:
	var atk = Attack.new()
	atk.damage = weapon_damage
	return atk
