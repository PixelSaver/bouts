extends Panel
class_name PlayerLobbyRow

signal kick_player(id: int)
@export_group("Nodes", "_")
@export var panel_color: Panel
@export var player_name: RichTextLabel
@export var kick_button: DefaultButton
var _player_info: PlayerInfo


func _ready() -> void:
	kick_button.pressed.connect(_on_kick)


func _on_kick() -> void:
	if _player_info:
		kick_player.emit(_player_info.id)


func load_player(pi: PlayerInfo):
	_player_info = pi
	var box = panel_color.get_theme_stylebox("panel").duplicate() as StyleBoxFancy
	box.color = pi.color
	player_name.text = pi.player_name
	kick_button.visible = (pi.id == multiplayer.get_unique_id() and multiplayer.is_server())
