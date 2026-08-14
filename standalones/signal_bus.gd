extends Node

#@warning_ignore("unused_signal")
#signal join(ip_address: String)
@warning_ignore("unused_signal")
signal player_disconnected
@warning_ignore("unused_signal")
## Called after server is initialized
signal hosted(
	lobby_name: String,
	password: String,
	public: bool,
	playerlimit: int,
	tags: Dictionary,
	data: Dictionary,
)
@warning_ignore("unused_signal")
signal joined(
	lobby_name: String,
	#password: String,
	#public: bool,
	#playerlimit: int,
	#tags: Dictionary,
	#data: Dictionary,
)
@warning_ignore("unused_signal")
signal kicked
@warning_ignore("unused_signal")
signal bullet_spawned(atk: Attack, rot: float, pos: Vector2, owned_id: int)
@warning_ignore("unused_signal")
signal player_info_changed(id: int, p_info: PlayerInfo)
@warning_ignore("unused_signal")
signal kick_player_requested(id: int)
#@warning_ignore("unused_signal")
#signal leave_requested()
@warning_ignore("unused_signal")
signal refresh_lobbies_requested()
