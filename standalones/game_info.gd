extends RefCounted
class_name GameInfo

const MAPS = MapManager.MapCollection

enum RoundType {
	BEST_OF,
	FIRST_TO,
	#TODO Add more round types / games / styles
	#MINiGAME,
}

signal player_info_changed(id: int, info: PlayerInfo)
signal data_changed(data: Dictionary)
@export var players: Dictionary[int, PlayerInfo] = { }:
	set(val):
		if players == val:
			return
		players = val
		_emit_data()
@export var win_history: Array[int] = []:
	set(val):
		if win_history == val:
			return
		win_history = val
		_emit_data()
@export var next_map: MAPS = MAPS.DEFAULT:
	set(val):
		if next_map == val:
			return
		next_map = val
		_emit_data()
@export var map_history: Array[int] = []:
	set(val):
		if map_history == val:
			return
		map_history = val
		_emit_data()
@export var current_round := -1:
	set(val):
		if current_round == val:
			return
		current_round = val
		_emit_data()
@export var round_type: RoundType = RoundType.BEST_OF
@export var rounds_out_of := 5:
	set(val):
		if rounds_out_of == val:
			return
		rounds_out_of = val
		_emit_data()


func reset() -> void:
	players = { }
	clear_game_history()


func clear_game_history() -> void:
	current_round = -1
	win_history = []
	next_map = MAPS.DEFAULT
	map_history = []

#region Player api
func clear_players() -> void:
	players.clear()
	_emit_data()


func erase_player(id: int) -> void:
	players.erase(id)
	_emit_data()


func add_or_change_pi(id: int, pi: PlayerInfo, sync_data: bool = false) -> void:
	if players.keys().count(id) == 0:
		pi.info_changed.connect(pi_change_func.bind(id))
	players.set(id, pi)
	player_info_changed.emit(id, pi)
	_emit_data()
	if sync_data and id == GDSync.get_client_id():
		Log.pr("Synced data")
		GDSync.player_set_data("player_info", pi.to_dict())


func pi_change_func(pi: PlayerInfo, id: int) -> void:
	player_info_changed.emit(id, pi)
	if id == GDSync.get_client_id():
		Log.pr("Synced data: %s" % pi.to_string())
		GDSync.player_set_data("player_info", pi.to_dict())


func add_player_win(id: int) -> bool:
	if win_history.size() > current_round and current_round != -1:
		Log.warn(
			"Round #%s has already been won by %s" % [current_round + 1, win_history[current_round]]
		)
		return false
	win_history.append(id)
	map_history.append(next_map)
	update_next_map()
	_emit_data()
	return true

#endregion

#region General API
func update_next_map() -> void:
	next_map = MAPS.values().pick_random()
	if OS.is_debug_build():
		next_map = MAPS.CHAINS


func start_new_round() -> void:
	current_round += 1
	if win_history.size() - 1 > current_round:
		Log.err("For some reason current round exceeds win history")


func change_game_settings(new_round_type: int, new_max_rounds: int) -> void:
	if new_max_rounds >= 0:
		self.rounds_out_of = new_max_rounds
	if new_round_type >= 0:
		self.round_type = new_round_type as RoundType
	_emit_data()


func get_game_winner() -> int:
	match round_type:
		RoundType.BEST_OF:
			var majority = float(rounds_out_of) / float(players.size())
			for player_id in players.keys():
				if get_wins(player_id) > majority:
					return player_id
		RoundType.FIRST_TO:
			for player_id in players.keys():
				if get_wins(player_id) >= rounds_out_of:
					return player_id
	return -1


func clear_win_history() -> void:
	win_history.clear()
#endregion

func to_dict() -> Dictionary:
	var players_dict: Dictionary[int, Dictionary] = { }
	for key in players.keys():
		var pi = players[key]
		players_dict.set(key, pi.to_dict())

	return {
		"players": players_dict,
		"win_history": win_history,
		"next_map": next_map,
		"map_history": map_history,
		"current_round": current_round,
		"round_type": round_type,
		"rounds_out_of": rounds_out_of,
	}


func get_wins(id: int) -> int:
	return win_history.count(id)


func get_host() -> PlayerInfo:
	var out: Array[PlayerInfo] = []
	for p in players.values():
		if p.is_host:
			out.append(p)
	return out[0]


func get_host_id() -> int:
	return get_host().id


func _to_string() -> String:
	return "%s" % self.player_states


func _emit_data() -> void:
	data_changed.emit(self.to_dict())


static func from_dict(dict: Dictionary) -> GameInfo:
	var info = GameInfo.new()
	var players_dict = dict.get("players", { })
	for key in players_dict.keys():
		info.players[key] = PlayerInfo.from_dict(players_dict[key])
	info.win_history = dict.get("win_history", [])
	info.next_map = dict.get("next_map", 0)
	info.map_history = dict.get("map_history", [])
	info.current_round = dict.get("current_round", -1)
	info.round_type = dict.get("round_type", RoundType.BEST_OF)
	info.rounds_out_of = dict.get("rounds_out_of", 5)
	return info
