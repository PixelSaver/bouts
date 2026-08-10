extends PixelMenu
class_name WaitingScreen

signal leave_requested
signal start_game_requested
@export var player_lobby_cont: Control
@export var start_game: DefaultButton
@export var leave_but: DefaultButton
const PLAYER_LOBBY_ROW = preload("res://scenes/menus/player_lobby_row.tscn")

var _enabled := false
#region old code
func _ready() -> void:
	start_game.pressed.connect(
		func():
			start_game_requested.emit(),
	)
	leave_but.pressed.connect(
		func():
			leave_requested.emit(),
	)

	_clear_lobby()
	#_update_player_list()
	Global.menu_manager.player_connected.connect(
		func(id: int):
			id = GDSync.get_client_id() if id == -1 else id
			_add_lobby_player(id)
			_update_player_list(),
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
	var keys = Global.menu_manager.game_info.players.keys()
	for i in range(keys.size()):
		var key = keys[i]
		_add_lobby_player(key)


func _add_lobby_player(id: int) -> void:
	var inst := PLAYER_LOBBY_ROW.instantiate() as PlayerLobbyRow
	player_lobby_cont.add_child(inst)
	inst.track_player_id(id)
#endregion

func start_anim() -> void:
	_enabled = true
	start_game.visible = GDSync.is_host()
	show()


func end_anim() -> void:
	_enabled = false
	hide()
