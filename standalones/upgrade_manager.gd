extends Node

enum Upgrades {
	HP_UP,
}
var cards : Dictionary[Upgrades, CardInfo] = {
	Upgrades.HP_UP: preload("res://assets/upgrades/hp_up.tres")
}
## When instantiating player scene, call this for each upgrade
func apply_upgrade(player:Player, upgrade_to_apply: Upgrades):
	match upgrade_to_apply:
		Upgrades.HP_UP:
			player._health_component.max_health *= 1.3
		_:
			pass

func get_card_info(upgrade:Upgrades) -> CardInfo:
	return cards.get(upgrade)

func get_random_upgrades(amount:int) -> Array[Upgrades]:
	amount = clampi(amount, 0, 100)
	var keys = cards.keys()
	#TODO Remove replacement when pickign randomly
	var out: Array[Upgrades] = []
	for i in range(amount):
		out.append(keys.pick_random())
	return out
