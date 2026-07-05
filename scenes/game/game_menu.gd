extends PixelMenu
class_name GameMenu

const PLAYER = preload("res://scenes/game/player.tscn")
@onready var players: Node2D = $Players
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer


func start_anim() -> void: 
	if not multiplayer.is_server(): return
	var keys = Global.menu_manager.players.keys()
	#print(keys.size())
	for i in range(keys.size()):
		var key = keys[i]
		var player_info: PlayerInfo = Global.menu_manager.players.get(key)
		if not player_info: 
			printerr("Player info not readable as PlayerInfo")
			continue
		spawn_player.rpc(player_info.id, Vector2(i * 100, 0))

@rpc("authority", "reliable", "call_local")
func spawn_player(id: int, pos: Vector2):
	var inst = PLAYER.instantiate()
	players.add_child(inst)
	await get_tree().process_frame
	inst.global_position = pos
	inst.set_multiplayer_authority(id)
	multiplayer_synchronizer.replication_config.add_property(str(get_path_to(inst)) + ":position")

func end_anim() -> void: 
	pass
