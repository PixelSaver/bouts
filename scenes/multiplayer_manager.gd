extends PixelMenuManager
class_name MultiplayerManager

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 6

var players : Dictionary[int, PlayerInfo]= {}
var player_info := PlayerInfo.new("Name")

signal player_connected(_peerID : int, _player_info : PlayerInfo)
signal player_disconnected(_peerID : int)
signal server_disconnected

func _ready() -> void:
	super()
	#Global.multiplayer_manager = self
	# Connect all the callbacks related to networking.
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_server_connected)
	multiplayer.connection_failed.connect(_server_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	SignalBus.host.connect(init_server)
	SignalBus.join.connect(join_server)
#region Network callbacks from SceneTree
# Callback from SceneTree.

## WHen one player connects and sends data to everyone
func _peer_connected(_id: int) -> void: 
	_register_player.rpc_id(_id, player_info.to_dict())
	print("Player Connected: ", _id)


func _peer_disconnected(_id: int) -> void:
	players.erase(_id)
	player_disconnected.emit(_id)
	
	if multiplayer.is_server():
		#_end_game("Client disconnected.")
		pass
	else:
		#_end_game("Server disconnected.")
		pass


## client connected to host
func _server_connected() -> void:
	_register_player.rpc_id(1, player_info.to_dict())


## Host connection failed
func _server_connection_failed() -> void:
	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	printerr("Server connection failed")

## Remove all info from server on disconnect
func _server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
#endregion

## called on everyone
@rpc("any_peer", "reliable")
func _register_player(_player_info_dict: Dictionary):
	var _player_info := PlayerInfo.from_dict(_player_info_dict)
	var new_player_id: int = multiplayer.get_remote_sender_id()
	players[new_player_id] = _player_info
	player_connected.emit(new_player_id, _player_info)
	print("Player Registered: ", _player_info)

func join_server(_address:String):
	if _address.is_empty():
		_address = DEFAULT_SERVER_IP
	
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = peer.create_client(_address, PORT)
	if error:
		push_error("JOIN GAME FAILED: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Connected!")

func init_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		push_error("CREATE GAME FAILED: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Server initiated")
	
	player_info.is_host = true
	var id := multiplayer.get_unique_id() # Should be 1
	players[id] = player_info
	player_connected.emit(id, player_info)
	
	SignalBus.hosted.emit()

func free_networking() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
