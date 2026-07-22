extends Resource
class_name RoundState

@export var player_states: Dictionary[int, int] = {}
@export var win_history: Array[int]

func add_player_win(id:int):
	win_history.append(id)

func get_wins(id:int) -> int:
	return win_history.count(id)

func _to_string() -> String:
	return "%s" % self.player_states
	
# func set_player_upgrades(id:int, upgrades:Array[UpgradeManager.Upgrades]):
# 	player_states.set(id, upgrades)

#func add_win(player_id:int) -> void:
	#if player_states.has(player_id):
		#var wins = get_wins(player_id)
		#player_states.set(player_id, wins + 1)
	#else:
		#player_states.set(player_id, 1)
#
#func get_wins(player_id: int) -> int:
	#return player_states.get(player_id, -1)
