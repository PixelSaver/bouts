extends Panel
class_name LobbyRow

@export_group("Nodes", "_")
@export var _name_label: RichTextLabel
@export var _player_count_label: RichTextLabel
@export var _password_protection_label: RichTextLabel
@export var _open_label: RichTextLabel
@export var _join_button: DefaultButton


func _ready() -> void:
	_join_button.pressed.connect(_on_join_button_pressed)


func _on_join_button_pressed() -> void:
	pass
