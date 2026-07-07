extends Node2D
class_name PlayerManager

signal player_won(id:int)
signal tie
var players_alive: Dictionary[int, Player] = {}

func register_player_in_game(id:int, player:Player):
	if players_alive.find_key(id) != null: return
	players_alive.set(id, player)
	player.died.connect(_on_player_died.bind(id))
	
func _on_player_died(id:int) -> void:
	players_alive.erase(id)
	_check_win()

func _check_win() -> void:
	if players_alive.size() == 1:
		player_won.emit(players_alive.keys().front())
	elif players_alive.size() == 0:
		tie.emit()
