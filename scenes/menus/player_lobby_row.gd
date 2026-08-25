extends Panel
class_name PlayerLobbyRow

@export_group("Nodes", "_")
@export var panel_color: Panel
@export var player_name: RichTextLabel
@export var host_display: Control
@export var kick_button: DefaultButton
var _client_id: int = -1
var _player_info: PlayerInfo
var _box: StyleBoxFancy


func _ready() -> void:
	kick_button.pressed.connect(_on_kick)
	_box = panel_color.get_theme_stylebox("panel").duplicate() as StyleBoxFancy
	panel_color.add_theme_stylebox_override("panel", _box)
	Global.menu_manager.game_info.player_info_changed.connect(_on_pi_changed)
	GDSync.player_data_changed.connect(_on_player_data_changed)


func _on_player_data_changed(client_id: int, key: String, value) -> void:
	if key != "player_info" or value is not Dictionary:
		Log.pr("Player info incorectly read | %s: %s" % [key, value])
		return
	var pi = PlayerInfo.from_dict(value)
	if not pi or client_id != _client_id:
		return
	pi.id = client_id
	load_player(pi)


func track_player_id(id: int) -> void:
	_client_id = id
	var pi_dict = GDSync.player_get_data(id, "player_info")
	if pi_dict == null:
		pi_dict = Global.menu_manager.game_info.players.get(id).to_dict()
	if pi_dict == null:
		await get_tree().create_timer(0.5).timeout
		track_player_id(id)
		return
	var pi = PlayerInfo.from_dict(pi_dict)
	if not pi:
		Log.err("Player info from GDSync did not convert to PlayerInfo well. %s" % pi_dict)
		return
	load_player(pi)


func _on_pi_changed(id: int, pi: PlayerInfo):
	if id != _client_id or _client_id == -1:
		return
	_box.color = pi.color


func _on_kick() -> void:
	if _player_info:
		GDSync.lobby_kick_client(_player_info.id)
		Global.notif_manager.create_notification(
			"Player Kicked!",
			"Just kicked player of name <%s> and id <%s>."
			% [_player_info.player_name, _player_info.id],
		)
		SignalBus.kick_player_requested.emit(_player_info.id)


func _is_me(pi: PlayerInfo) -> bool:
	return GDSync.get_client_id() == pi.id


func load_player(pi: PlayerInfo):
	_player_info = pi
	_box.color = pi.color
	player_name.text = "%s (me)" % pi.player_name if _is_me(pi) else pi.player_name
	kick_button.visible = (pi.id != GDSync.get_client_id() and GDSync.is_host())
	host_display.visible = pi.id == GDSync.get_host()
