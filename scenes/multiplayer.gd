extends Node
#class_name MultiplayerManager
#
#const PORT = 7000
#const DEFAULT_SERVER_IP = "127.0.0.1"
#const MAX_CONNECTIONS = 6
#
#var players = {}
#
#signal player_connected(_peerID : int, _player_info : Dictionary)
#signal player_disconnected(_peerID : int)
#signal server_disconnected
#
#func _ready() -> void:
	#Global.multiplayer_manager = self
	## Connect all the callbacks related to networking.
	#multiplayer.peer_connected.connect(_player_connected)
	#multiplayer.peer_disconnected.connect(_player_disconnected)
	#multiplayer.connected_to_server.connect(_connected_ok)
	#multiplayer.connection_failed.connect(_connected_fail)
	#multiplayer.server_disconnected.connect(_server_disconnected)
##region Network callbacks from SceneTree
## Callback from SceneTree.
#func _player_connected(_id: int) -> void:
	## Someone connected, start the game!
	#var pong: Node2D = load("res://pong.tscn").instantiate()
	## Connect deferred so we can safely erase it from the callback.
	##pong.game_finished.connect(_end_game, CONNECT_DEFERRED)
#
	##get_tree().get_root().add_child(pong)
	##hide()
#
#
#func _player_disconnected(_id: int) -> void:
	#if multiplayer.is_server():
		#_end_game("Client disconnected.")
	#else:
		#_end_game("Server disconnected.")
#
#
## Callback from SceneTree, only for clients (not server).
#func _connected_ok() -> void:
	#pass # This function is not needed for this project.
#
#
## Callback from SceneTree, only for clients (not server).
#func _connected_fail() -> void:
	#_set_status("Couldn't connect.", false)
#
	#multiplayer.set_multiplayer_peer(null)  # Remove peer.
	#host_button.set_disabled(false)
	#join_button.set_disabled(false)
#
#
#func _server_disconnected() -> void:
	#_end_game("Server disconnected.")
##endregion
#func join_server(_address:String):
	#if _address.is_empty():
		#_address = DEFAULT_SERVER_IP
	#
	#var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	#var error = peer.create_client(_address, PORT)
	#if error:
		#printerr("JOIN GAME FAILED: ", error)
		#return
#
#func init_server() -> void:
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(PORT, MAX_CONNECTIONS)
	#if error:
		#printerr("CREATE GAME FAILED: ", error)
		#return
	#multiplayer.multiplayer_peer = peer
#
#func free_networking() -> void:
	#multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
