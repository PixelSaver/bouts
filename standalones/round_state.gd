extends Resource
class_name RoundState

@export var player_states: Dictionary[int, Array] = {}

func set_player_upgrades(id:int, upgrades:Array[UpgradeManager.Upgrades]):
	player_states.set(id, upgrades)
