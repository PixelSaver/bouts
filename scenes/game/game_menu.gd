extends PixelMenu
class_name GameMenu

const PLAYER = preload("res://scenes/active_ragdoll/player.tscn")
#"res://scenes/game/player_old.tscn"
@onready var players: Node2D = $Players
@onready var bullet_manager: Node2D = $BulletManager
@onready var player_manager: PlayerManager = $Players

func _ready() -> void:
	if multiplayer.is_server():
		player_manager.player_won.connect(func(id:int):
			var ups = UpgradeManager.get_random_upgrades(5)
			Global.round_state = RoundState.new()
			Global.player_won_id = id
			#TODO Upgrade to 4 player
			Global.round_state.set_player_upgrades(Global.get_losers().front(), ups)
			print("On server, round state: %s" % Global.round_state)
			for _id in Global.menu_manager.players.keys():
				if _id == 1: continue
				receive_upgrades.rpc_id(_id, id, ups)
			player_won.rpc(id)
		)
		player_manager.tie.connect(func():
			player_won.rpc(-1)
		)

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
		spawn_player.rpc(key, Vector2(i * 500, 0), player_info.upgrades)
@rpc("authority", "reliable", "call_local")
func spawn_player(id: int, pos: Vector2, ups:Array[UpgradeManager.Upgrades]):
	var inst = PLAYER.instantiate()
	players.add_child(inst)
	#inst.apply_upgrades(ups)
	#await get_tree().process_frame
	inst.global_position = pos
	inst.set_multiplayer_authority(id)
	player_manager.register_player_in_game(id, inst)

@rpc("any_peer", "reliable", "call_remote")
func receive_upgrades(win_id:int, upgrades:Array[UpgradeManager.Upgrades]):
	#HACK Update winners and losers better, clean up al the Global.player_won_id = id and stuff
	Global.player_won_id = win_id
	Global.round_state = RoundState.new()
	#TODO Upgrade to 4 player
	Global.round_state.set_player_upgrades(Global.get_losers().front(), upgrades)

@rpc("authority", "call_local", "reliable")
func player_won(id:int) -> void:
	player_manager.stop_player_sync()
	Global.player_won_id = id
	print("Client %s sees %s won" % [self.multiplayer.get_unique_id(), id])
	await get_tree().process_frame
	await get_tree().process_frame
	if id == -1: 
		# tie
		pass
	else:
		Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.CARDS))

func end_anim() -> void: 
	queue_free()
