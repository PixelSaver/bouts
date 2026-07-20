## Weapon manager
extends Node

enum Weapons {
	
}
var weapons: Dictionary[Weapons, PackedScene] = {
	
}
func get_weapon(weapon: Weapons) -> PackedScene:
	return weapons[weapon]
