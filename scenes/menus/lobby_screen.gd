extends PixelMenu
class_name LobbyScreen

const LOBBY_ROW := preload("res://scenes/menus/lobby_row.tscn")
var last_refresh := 0.

#region Fluff
func start_anim():
	pass


func end_anim():
	pass
#endregion

func _ready() -> void:
	GDSync.lobbies_received.connect(_on_lobbies_received)
	SignalBus.refresh_lobbies_requested.connect(_on_refresh)


func _on_lobbies_received(lobbies: Array):
	print("Lobbies received: %s" % str(lobbies))


func _on_refresh() -> void:
	last_refresh = 0.


func _process(_delta):
	#	Refresh the lobby list every 5 seconds
	var current_time: float = Time.get_unix_time_from_system()
	if current_time - last_refresh >= 5.:
		last_refresh = current_time

		#		Request all publicly visible lobbies and wait for the signal to fire
		GDSync.get_public_lobbies()
