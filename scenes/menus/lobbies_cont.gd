extends HBoxContainer
class_name LobbyScanContainer

const LOBBY_ROW = preload("res://scenes/menus/lobby_row.tscn")

signal join_lobby_requested
@export_group("Nodes", "_")
@export var _lobby_cont: Control

var is_scanning := false
var last_refresh: float = 0


func _ready() -> void:
	GDSync.lobbies_received.connect(lobbies_received)


func _process(_delta):
	if not is_scanning:
		return
	#	Refresh the lobby list every 5 seconds
	var current_time: float = Time.get_unix_time_from_system()
	if current_time - last_refresh >= 5:
		last_refresh = current_time

		#		Request all publicly visible lobbies and wait for the signal to fire
		GDSync.get_public_lobbies()


func lobbies_received(lobbies: Array) -> void:
	#	Display all lobbies using UI elements
	var lobby_labels: Array = _lobby_cont.get_children()

	#	Mark all currently displayed lobbies for deletion
	for label in lobby_labels:
		label.set_meta("delete", true)

	for lobby_data in lobbies:
		var lobby_name: String = lobby_data["Name"]
		var lobby_label: LobbyRow = _lobby_cont.get_node_or_null(lobby_name)

		if lobby_label == null:
			lobby_label = LOBBY_ROW.instantiate()
			lobby_label.join_pressed.connect(lobby_join_pressed)
			_lobby_cont.add_child(lobby_label)

		#Cancel deletion if the lobby still exists
		lobby_label.set_meta("delete", false)
		lobby_label.load_lobby_info(LobbyInfo.from_dict(lobby_data))

	#	Delete all old displayed lobbies
	for label in lobby_labels:
		if label.get_meta("delete"):
			label.queue_free()


func lobby_join_pressed(lobby_name: String, has_password: bool):
	join_lobby_requested.emit(lobby_name, has_password)
