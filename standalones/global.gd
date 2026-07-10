extends Node

enum States {
	START,
}
var state : States = States.START

var menu_manager: MultiplayerManager

#var multiplayer_manager: MultiplayerManager

var player_won_id := -1
func get_losers() -> Array[int]:
	if player_won_id == -1 or !menu_manager: return []
	var out: Array[int] = []
	for p in (menu_manager.players.values() as Array[PlayerInfo]):
		if p.id != player_won_id: out.append(p.id)
	return out
