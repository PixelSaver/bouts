extends PixelMenu
class_name GameMenu

const PLAYER = preload("res://scenes/active_ragdoll/player.tscn")
#"res://scenes/game/player_old.tscn"
@export var map_man: MapManager
@export var banners_cont: Control
@export var camera: PhantomCamera2D
@export var text_cont: Control
@onready var players: Node2D = $Players
@onready var player_manager: PlayerManager = $Players
var mouse_mode: Input.MouseMode = Input.MouseMode.MOUSE_MODE_VISIBLE
var t: Tween
var _game_info: GameInfo


func _ready() -> void:
	GDSync.expose_func(spawn_player)
	GDSync.expose_func(player_won)
	GDSync.expose_func(end_game_for_all)

	if GDSync.is_host():
		player_manager.player_won.connect(
			func(id: int):
				#var ups = UpgradeManager.get_random_upgrades(5)
				#Global.round_state = RoundState.new()
				Global.player_won_id = id
				#TODO Upgrade to 4 player
				#Global.round_state.set_player_upgrades(Global.get_losers().front(), ups)
				#print("On server, round state: %s" % Global.round_state)
				#for _id in Global.menu_manager.players.keys():
				#if _id == 1: continue
				#receive_upgrades.rpc_id(_id, id, ups)
				GDSync.call_func_all(player_won, id),
		)
		player_manager.tie.connect(
			func():
				GDSync.call_func_all(player_won, -1),
		)
	var banner_ts = get_all_tweenables(banners_cont)
	for tw in banner_ts:
		tw.tween_value = 1.0
		tw.modulate_parent.a = 1.0
	SignalBus.player_disconnected.connect(
		func():
			end_game_for_all(),
	)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("l_click"):
		mouse_mode = Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("esc"):
		mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func pass_game_info(game_info: GameInfo) -> void:
	_game_info = game_info
	SignalBus.round_started.emit(_game_info)
	Log.pr("Round started")
	start_anim()


func start_anim() -> void:
	if not _game_info:
		return
	var keys = _game_info.players.keys()

	# animation
	var all_ts = get_all_tweenables(self)
	for tw in all_ts:
		tw.tween_value = 1.0
		tw.modulate_parent.a = 1.0
	if t and t.is_running():
		t.kill()
	t = default_tween()

	# Banners
	var banner_ts = get_all_tweenables(banners_cont)
	for tw in banner_ts:
		t.tween_property(tw, "tween_value", 0., 0.7)
	await t.finished

	# text
	await text_cont.animate(_game_info.get_wins(keys[0]), _game_info.get_wins(keys[1]))

	# bounce
	t = default_tween().set_parallel(false).set_trans(Tween.TRANS_CIRC)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(text_cont, "offset_transform_scale", Vector2.ONE * 1.3, 0.3)
	t.set_ease(Tween.EASE_IN)
	t.tween_property(text_cont, "offset_transform_scale", Vector2.ONE, 0.3)
	await t.finished
	t = default_tween()
	for tw in all_ts:
		t.tween_property(tw, "tween_value", 1.0, 0.7)
		t.tween_property(tw, "modulate_parent:a", 0.0, 0.7)

	if not GDSync.is_host():
		return

	var spawns = map_man.get_spawn_points()
	if keys.size() > spawns.size():
		Log.err(
			"Spawns on the map are not enough to accomodate all players. \nKeys: %s\nSpawns: %s"
			% [keys, spawns]
		)
		return
	for i in range(keys.size()):
		var key = keys[i]
		var player_info: PlayerInfo = _game_info.players.get(key)
		if not player_info:
			Log.warn("Player info not readable as PlayerInfo")
			continue
		GDSync.call_func_all(spawn_player, key, spawns[i], player_info.to_dict())


#@rpc("authority", "reliable", "call_local")
func spawn_player(id: int, pos: Vector2, _pi: Dictionary):
	if id == GDSync.get_client_id():
		Log.pr("Player spawned of this info: %s" % PlayerInfo.from_dict(_pi))
	var pi = PlayerInfo.from_dict(_pi)
	var inst = PLAYER.instantiate() as Player
	players.add_child(inst)
	#inst.apply_upgrades(ups)
	#await get_tree().process_frame
	inst.name = "Player_%d" % id
	inst.set_color(pi.color)
	inst.global_position = pos
	inst.bind_weapon(pi.weapon)
	GDSync.set_gdsync_owner(inst, id)
	#inst.set_multiplayer_authority(id)
	camera.append_follow_targets(inst.get_cam_follow_node())
	inst.begin_round(_game_info)
	player_manager.register_player_in_game(id, inst)


func player_won(id: int) -> void:
	player_manager.stop_player_sync()
	# ignore true win since if tie js do another round :P
	var _true_win = Global.set_winner(id)
	Log.pr("Client %s sees %s win" % [GDSync.get_client_id(), id])
	if not GDSync.is_host():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var game_winner := _game_info.get_game_winner()
	if game_winner == -1:
		Global.menu_manager.request_start_game()
	else:
		Log.pr("Player %s won the game!" % game_winner)
		GDSync.call_func_all(end_game_for_all)


func end_game_for_all() -> void:
	_game_info.clear_win_history()
	Global.menu_manager.transition_to_scene(
		SceneDatabase.get_scene(SceneDatabase.Scene.MULTIPLAYER)
	)


func end_anim() -> void:
	self.hide()
	await get_tree().create_timer(.5).timeout
	$PhantomCamera2D.hide()
	$PhantomCamera2D.queue_free()
	$Camera2D.hide()
	$Camera2D.queue_free()
	queue_free()
