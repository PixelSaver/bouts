extends PixelMenu
class_name LobbiesScreen

const LOBBY_ROW := preload("res://scenes/menus/lobby_row.tscn")
@export var scan_cont: LobbyScanContainer
@export var lobby_popup: PasswordPopup
@export var join_lobby_but: DefaultButton
var last_refresh := 0.

#region Fluff
func start_anim():
	scan_cont.is_scanning = true
	show()


func end_anim():
	scan_cont.is_scanning = false
	hide()
#endregion

func _ready() -> void:
	GDSync.lobbies_received.connect(_on_lobbies_received)
	SignalBus.refresh_lobbies_requested.connect(_on_refresh)
	scan_cont.join_lobby_requested.connect(_on_join_lobby_requested)
	lobby_popup.lobby_canceled.connect(_on_lobby_join_canceled)
	lobby_popup.lobby_submitted.connect(_on_join_lobby_requested_with_password)
	join_lobby_but.pressed.connect(_on_join_lobby_requested_custom)


func _on_lobby_join_canceled() -> void:
	lobby_popup.end_anim()


func _on_join_lobby_requested_custom() -> void:
	lobby_popup.prompt_lobby_input()


func _on_join_lobby_requested_with_password(lobby_name: String, password: String) -> void:
	GDSync.lobby_join(lobby_name, password)
	lobby_popup.end_anim()


func _on_join_lobby_requested(lobby_name: String, has_password: bool) -> void:
	Log.pr("Join lobby reqested")
	if has_password:
		lobby_popup.prompt_lobby_input(lobby_name)
	else:
		GDSync.lobby_join(lobby_name)


func _on_lobbies_received(lobbies: Array):
	#print("Lobbies received: %s" % str(lobbies))
	pass


func _on_refresh() -> void:
	last_refresh = 0.


func _process(_delta):
	#	Refresh the lobby list every 5 seconds
	var current_time: float = Time.get_unix_time_from_system()
	if current_time - last_refresh >= 5.:
		last_refresh = current_time

		#		Request all publicly visible lobbies and wait for the signal to fire
		GDSync.get_public_lobbies()
