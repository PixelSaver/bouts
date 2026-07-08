extends Node

enum Upgrades {
	
}
var cards : Dictionary[Upgrades, PackedScene]= {
	
}
## When instantiating player scene, call this for each upgrade
func apply_upgrade(player:Player, upgrade_to_apply: Upgrades):
	match upgrade_to_apply:
		_:
			pass
