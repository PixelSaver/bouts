extends Node

@warning_ignore("unused_signal")
signal test(test: bool)
@warning_ignore("unused_signal")
signal join(ip_address: String)
@warning_ignore("unused_signal")
signal host
@warning_ignore("unused_signal")
## Called after server is initialized
signal hosted
@warning_ignore("unused_signal")
signal bullet_spawned(atk:Attack, rot:float, pos:Vector2, owned_id:int)
@warning_ignore("unused_signal")
signal player_info_changed(p_info:PlayerInfo)
