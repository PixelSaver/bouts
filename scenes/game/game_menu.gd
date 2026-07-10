extends PixelMenu
class_name GameMenu

const PLAYER = preload("res://scenes/game/player.tscn")
@onready var players: Node2D = $Players
@onready var bullet_manager: Node2D = $BulletManager
@onready var player_manager: PlayerManager = $Players

func _ready() -> void:
	if multiplayer.is_server():
		player_manager.player_won.connect(func(id:int):
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
		spawn_player.rpc(key, Vector2(i * 100, 0))
@rpc("authority", "reliable", "call_local")
func spawn_player(id: int, pos: Vector2):
	var inst = PLAYER.instantiate()
	players.add_child(inst)
	await get_tree().process_frame
	inst.global_position = pos
	inst.set_multiplayer_authority(id)
	player_manager.register_player_in_game(id, inst)

@rpc("authority", "call_local", "reliable")
func player_won(id:int) -> void:
	player_manager.stop_player_sync()
	await get_tree().process_frame
	await get_tree().process_frame
	if id == -1: 
		# tie
		pass
	else:
		Global.player_won_id = id
		Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.CARDS))

func end_anim() -> void: 
	queue_free()
