extends PixelMenu
class_name WaitingScreen

@export var player_lobby_cont: Control
const PLAYER_LOBBY_ROW = preload("res://scenes/menus/player_lobby_row.tscn")


func _ready() -> void:
	_clear_lobby()
	#_update_player_list()
	Global.menu_manager.player_connected.connect(
		func(_x, pi: PlayerInfo):
			_add_lobby_player(pi),
	)
	Global.menu_manager.player_disconnected.connect(
		func(_x):
			_update_player_list(),
	)


func _clear_lobby() -> void:
	for child in player_lobby_cont.get_children():
		child.queue_free()


func _update_player_list() -> void:
	_clear_lobby()
	var keys = Global.menu_manager.players.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var player_info: PlayerInfo = Global.menu_manager.players.get(key)
		if not player_info:
			printerr("Player info not readable as PlayerInfo")
			continue
		var inst := PLAYER_LOBBY_ROW.instantiate() as PlayerLobbyRow
		player_lobby_cont.add_child(inst)
		inst.load_player(player_info)


func _add_lobby_player(player_info: PlayerInfo) -> void:
	var inst := PLAYER_LOBBY_ROW.instantiate() as PlayerLobbyRow
	player_lobby_cont.add_child(inst)
	inst.load_player(player_info)


func start_anim() -> void:
	show()


func end_anim() -> void:
	hide()
