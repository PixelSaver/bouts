## Weapon manager
extends Node

enum WeaponType {
	SWORD,
	MACE,
	GUN,
}
var weapons: Dictionary[WeaponType, PackedScene] = {
	WeaponType.SWORD: preload("res://scenes/weapons/generic_sword.tscn"),
	WeaponType.MACE: preload("res://scenes/weapons/mace.tscn"),
	WeaponType.GUN: preload("res://scenes/weapons/gun.tscn"),
	#WeaponType.MACE: preload(),
}


func get_all_weapon_types_str() -> Array[String]:
	var out: Array[String] = []
	for w_name in WeaponType.keys() as Array[String]:
		Log.pr("Weapon name: %s" % w_name)
		out.append(w_name.capitalize())
	return out


func get_weapon(weapon: WeaponType) -> PackedScene:
	return weapons[weapon]
