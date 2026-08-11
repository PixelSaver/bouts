extends PixelMenuManager
class_name MultiplayerManager

#const PORT = 7000
#const DEFAULT_SERVER_IP = "127.0.0.1"
#const MAX_CONNECTIONS = 6

signal game_start_requested(game_info_dict: Dictionary)
var game_info: GameInfo = GameInfo.new()
#var players: Dictionary[int, PlayerInfo] = { }
@onready var player_info := PlayerInfo.new("%.5f" % randf())
signal gdsync_connection_changed(is_connected: bool)
signal gdsync_lobby_responded(lobby_name: String, error: int)
var is_gdsync_connected := false:
	set(val):
		if val == is_gdsync_connected:
			return

		is_gdsync_connected = val
		gdsync_connection_changed.emit(val)
var _created_lobby_password := ""

signal player_connected(_peerID: int)
signal player_disconnected(_peerID: int)


func _ready() -> void:
	super()
	GDSync.connected.connect(_on_connected)
	GDSync.connection_failed.connect(_on_connection_failed)
	GDSync.disconnected.connect(_on_disconnected)
	GDSync.start_multiplayer()

	GDSync.client_joined.connect(_peer_connected)
	GDSync.client_left.connect(_peer_disconnected)
	GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_creation_failed.connect(lobby_creation_failed)
	GDSync.lobby_joined.connect(_on_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_lobby_join_failed)
	GDSync.player_data_changed.connect(_on_pi_changed)

	GDSync.kicked.connect(_on_kicked)

	self.player_connected.connect(_on_player_connected)
	self.player_disconnected.connect(_on_player_disconnected)

	#GDSync.expose_signal(game_start_requested)
	GDSync.expose_func(_on_game_start)
	game_start_requested.connect(_on_game_start)

	player_info.info_changed.connect(
		func(new_info: PlayerInfo):
			SignalBus.player_info_changed.emit(-1, new_info)
			if not GDSync.is_active():
				return
				#TODO Queue callback for when gdsync is active to set the color
			GDSync.player_set_data("player_info", new_info.to_dict()),
	)

	#TODO Make disconnection work with 4 players, checking if you're the last person in lobby
	_randomize_color()


func _randomize_color() -> void:
	print("Randomizing color")
	player_info.color = Color(randf(), randf(), randf())

#region old_colde
# Callback from SceneTree.

## WHen one player connects, send data over as server
#func _peer_connected(_id: int) -> void:
#if not GDSync.is_host():
#return
## Sending server data to peer
#_register_player.rpc_id(_id, player_info.to_dict())
#print("Player Connected: ", _id)
#
#
#func _peer_disconnected(_id: int) -> void:
#push_warning("Peer %s disconnected" % _id)
#players.erase(_id)
#player_disconnected.emit(_id)
#
#if GDSync.is_host():
##_end_game("Client disconnected.")
#pass
#else:
##_end_game("Server disconnected.")
#pass

### client connected to host
#func _server_connected() -> void:
#print("_server_connected")
#player_info.id = multiplayer.get_unique_id()
#_register_player.rpc_id(1, player_info.to_dict())
#
#
### Host connection failed
#func _server_connection_failed() -> void:
#multiplayer.set_multiplayer_peer(null) # Remove peer.
#printerr("Server connection failed")
#
#
### Remove all info from server on disconnect
#func _server_disconnected() -> void:
#push_warning("Server disconnected")
#multiplayer.multiplayer_peer = null
#players.clear()
#server_disconnected.emit()

### called on everyone
#@rpc("any_peer", "reliable")
#func _register_player(_player_info_dict: Dictionary):
#var _player_info := PlayerInfo.from_dict(_player_info_dict)
#players.set(_player_info.id, _player_info)
#player_connected.emit(_player_info.id, _player_info)
#print("Player Registered on client %s: %s" % [multiplayer.get_unique_id(), _player_info])

#func join_server(_address: String):
#if _address.is_empty():
#_address = DEFAULT_SERVER_IP
#
#var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
#var error = peer.create_client(_address, PORT)
#if error:
#push_error("JOIN GAME FAILED: ", error)
#return
#multiplayer.multiplayer_peer = peer
#player_info.id = multiplayer.get_unique_id()
#_register_player(player_info.to_dict())
#print("Connected!")
#endregion

#region GDSync connection
func _on_connected() -> void:
	player_info.is_host = GDSync.is_host()
	player_info.id = GDSync.get_client_id()
	GDSync.player_set_data("player_info", player_info.to_dict())
	GDSync.player_set_username(str(GDSync.get_client_id()))
	is_gdsync_connected = true
	print("Connected to GDSync")


func _on_connection_failed(error: int) -> void:
	var error_str: String
	match (error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			error_str = ("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			error_str = ("Unable to connect, please check your internet connection.")
	Global.notif_manager.create_notification("Connection Error", error_str)


func _on_disconnected() -> void:
	is_gdsync_connected = false


func _on_kicked() -> void:
	Log.pr("Got kicked!! client %s" % GDSync.get_client_id())
	Global.notif_manager.create_notification(
		"You were kicked!",
		"Unfortunately, the host kicked you out. Be respectful the next time please?",
	)
	SignalBus.kicked.emit()

#endregion
#region Client connection and disconnetion
func _peer_connected(id: int) -> void:
	player_connected.emit(id)


func _peer_disconnected(id: int) -> void:
	player_disconnected.emit(id)
#endregion

#region PLayer data
func _on_player_connected(id: int) -> void:
	var pi_dict = GDSync.player_get_data(id, "player_info")
	var pi = PlayerInfo.from_dict(pi_dict)
	game_info.add_or_change_pi(id, pi, false)


func _on_player_disconnected(id: int) -> void:
	game_info.erase_player(id)


func _on_pi_changed(client_id: int, key: String, value) -> void:
	if key != "player_info" or value is not Dictionary:
		Log.pr("Player info is %s: %s" % [key, value])
		return
	var pi = PlayerInfo.from_dict(value)
	pi.id = client_id
	if not pi or client_id != GDSync.get_client_id():
		return
	game_info.add_or_change_pi(client_id, pi, false)
#endregion

#region Lobby stuff
func create_lobby(
	lobby_name: String,
	password: String,
	public: bool,
	playerlimit: int,
	tags: Dictionary = { },
	data: Dictionary = { },
) -> void:
	_created_lobby_password = password
	GDSync.lobby_create(lobby_name, password, public, playerlimit, tags, data)
	self.player_info.is_host = true
	SignalBus.hosted.emit(lobby_name, password, public, playerlimit, tags, data)


func try_join_lobby(lobby_name: String, password: String = "") -> void:
	GDSync.lobby_join(lobby_name, password)


func lobby_created(lobby_name: String) -> void:
	gdsync_lobby_responded.emit(lobby_name, -1)
	try_join_lobby(lobby_name, _created_lobby_password)
	print("Lobby of name <%s> made!" % lobby_name)


func lobby_creation_failed(lobby_name: String, error: int):
	var error_str = ""
	match (error):
		ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
			error_str = ("A lobby with the name " + lobby_name + " already exists.")
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_SHORT:
			error_str = (lobby_name + " is too short.")
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_LONG:
			error_str = (lobby_name + " is too long.")
		ENUMS.LOBBY_CREATION_ERROR.PASSWORD_TOO_LONG:
			error_str = ("The password for " + lobby_name + " is too long.")
		ENUMS.LOBBY_CREATION_ERROR.TAGS_TOO_LARGE:
			error_str = ("The tags have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.DATA_TOO_LARGE:
			error_str = ("The data have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.ON_COOLDOWN:
			error_str = ("Please wait a few seconds before creating another lobby.")
	gdsync_lobby_responded.emit(lobby_name, error_str)
	Global.notif_manager.create_notification("Lobby Creation Error", error_str)
	if not error_str.is_empty():
		push_warning(error_str)


func _on_lobby_joined(lobby_name: String) -> void:
	player_info.force_update_host()
	SignalBus.joined.emit(lobby_name)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	var error_str = ENUMS.LOBBY_JOIN_ERROR.keys()[error]
	Log.err("Failed to join %s, because of: %s" % [lobby_name, error_str])

#endregion

func free_networking() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

#region Leave Lobby
func request_leave_lobby() -> void:
	GDSync.lobby_leave()
	game_info.clear_players()
#endregion

#region Game start
func request_start_game() -> void:
	if not GDSync.is_host():
		#TODO Write host logic for showing and transferring
		return
	game_info.start_new_round()
	GDSync.call_func_all(_on_game_start, game_info.to_dict())
	#GDSync.emit_signal_remote_all(game_start_requested, game_info.to_dict())


func _on_game_start(game_info_dict: Dictionary) -> void:
	Log.pr("Client %s is going to new game" % GDSync.get_client_id())
	var gi = GameInfo.from_dict(game_info_dict)
	if not gi:
		Log.err("Game info not parsed correctly")
		return
	game_info = gi
	self.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.GAME), true)
	var game = current_scene as GameMenu
	game.pass_game_info(game_info)
#endregion
