extends Panel
class_name LobbyRow

signal join_pressed(lobby_name: String, has_password: bool)
@export_group("Nodes", "_")
@export var _name_label: RichTextLabel
@export var _player_count_label: RichTextLabel
@export var _password_protection_label: RichTextLabel
@export var _open_label: RichTextLabel
@export var _join_button: DefaultButton

var _has_password := false


func _ready() -> void:
	_join_button.pressed.connect(_on_join_button_pressed)


func load_lobby_info(li: LobbyInfo) -> void:
	_has_password = li.lobby_has_password
	_name_label.text = li.lobby_name
	_player_count_label.text = str(li.lobby_player_count)
	_open_label.text = str(li.lobby_is_open)


func _on_join_button_pressed() -> void:
	#TODO Add the password thing
	join_pressed.emit(_name_label.text, _has_password)
