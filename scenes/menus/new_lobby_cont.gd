extends Panel
class_name NewLobbyCont

@export_group("Nodes", "_")
@export var _name_edit: LineEdit
@export var _player_count_edit: LineEdit
@export var _password_edit: LineEdit
@export var _public_edit: CheckBox
@export var _create_lobby_button: DefaultButton


func _ready() -> void:
	_create_lobby_button.pressed.connect(_on_create_lobby_pressed)


func _on_create_lobby_pressed() -> void:
	if _name_edit.text.is_empty():
		Log.pr("Lobby Name is empty")
		return
	if _player_count_edit.text.is_empty():
		Log.pr("Player count is empty")
		return
	var player_limit: int = int(_player_count_edit.text)
	if player_limit == null or player_limit != clampi(player_limit, 2, 4):
		Global.notif_manager.create_notification(
			"Lobby Creation Error",
			"Player Limit isn't 2-4, its %s" % player_limit,
		)
		Log.pr("Player Limit isn't 2-4, its %s" % player_limit)
		return
	var is_public = _public_edit.button_pressed

	Global.menu_manager.create_lobby(
		_name_edit.text,
		_password_edit.text,
		is_public,
		player_limit,
		{ },
	)
	#HACK Waiting two frames for lobby to be seen
	await get_tree().process_frame
	await get_tree().process_frame
	SignalBus.refresh_lobbies_requested.emit()
