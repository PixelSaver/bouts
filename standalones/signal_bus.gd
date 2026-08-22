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
signal projectile_spawn_requested(
	p_type: ProjectileManager.ProjectileType,
	atk: Attack,
	rot: float,
	pos: Vector2,
	linear_velocity: Vector2,
	owned_id: int,
)
@warning_ignore("unused_signal")
signal unregister_projectile_requested(id: int)
@warning_ignore("unused_signal")
signal projectile_spawned(p: Projectile, owned_id: int)
@warning_ignore("unused_signal")
signal player_info_changed(id: int, p_info: PlayerInfo)
@warning_ignore("unused_signal")
signal player_skill_cooldown_changed(cooldown: float, max_cooldown: float)
@warning_ignore("unused_signal")
signal kick_player_requested(id: int)
#@warning_ignore("unused_signal")
#signal leave_requested()
@warning_ignore("unused_signal")
signal refresh_lobbies_requested()
@warning_ignore("unused_signal")
signal round_started(game_info: GameInfo)
