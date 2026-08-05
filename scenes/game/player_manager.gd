extends Node2D
class_name PlayerManager

signal player_won(id: int)
signal tie
var players_alive: Dictionary[int, Player] = { }
var game_ended := false


func register_player_in_game(id: int, player: Player):
	if players_alive.keys().has(id):
		return
	players_alive.set(id, player)
	player.died.connect(_on_player_died.bind(id))


func stop_player_sync() -> void:
	for child in get_children():
		if child is Player:
			var player = child as Player
			player.set_disable(Player.DisableMode.NOTHING)


func _on_player_died(id: int) -> void:
	print("Player died: %s" % id)
	players_alive.erase(id)
	_check_win()


func _check_win() -> void:
	if game_ended:
		return
	if players_alive.size() == 1:
		var winner_id = players_alive.keys().front()
		print("Player won: %s on client %s" % [winner_id, multiplayer.get_unique_id()])
		player_won.emit(winner_id)
		game_ended = true
	elif players_alive.size() == 0:
		tie.emit()
		game_ended = true
