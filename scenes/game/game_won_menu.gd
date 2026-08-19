extends PixelMenu
class_name GameWonMenu

@export var buttons: Array[DefaultButton]
@export var winner_label: RichTextLabel
@export var score_label: RichTextLabel
@export var player: Player
var all_t: Array[Tweenable] = []
var t: Tween
var _game_info: GameInfo


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_but_pressed.bind(but.name.to_lower()))
	GDSync.expose_func(back_to_lobby)
	GDSync.expose_func(next_game)


func back_to_lobby() -> void:
	Global.menu_manager.transition_to_scene(
		SceneDatabase.get_scene(SceneDatabase.Scene.MULTIPLAYER),
		true,
	)


func next_game(gi: Dictionary) -> void:
	_game_info.clear_game_history()
	var game_menu: GameMenu = Global.menu_manager.transition_to_scene(
		SceneDatabase.get_scene(SceneDatabase.Scene.GAME),
		true,
	)
	game_menu.pass_game_info(GameInfo.from_dict(gi))


func _on_but_pressed(but_name: String) -> void:
	if not GDSync.is_host():
		Global.notif_manager.create_notification(
			"Not the host",
			"You can't go to next game or back to lobby unless you are host.",
		)
		return
	match but_name.to_lower():
		"backtolobby":
			GDSync.call_func_all(back_to_lobby)
		"nextgame":
			GDSync.call_func_all(next_game, _game_info.to_dict())


func start_anim() -> void:
	if not _game_info:
		return
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		table.tween_value = 0.
		t.tween_property(table, "tween_value", 1.0, 5.5)


func pass_game_info(game_info: GameInfo, winner_id: int = -1) -> void:
	_game_info = game_info
	var winner_pi: PlayerInfo = _game_info.players.get(winner_id, PlayerInfo.new())
	Log.pr("Winner pi: %s, id was %s" % [winner_pi, winner_id])
	winner_label.text = "%s Wins (Player #%s)" % [
		winner_pi.player_name,
		winner_id,
	]
	player.set_color(winner_pi.color)
	player.bind_weapon(winner_pi.weapon)
	score_label.clear()
	var score_text = "Player scores:"
	for id in game_info.players.keys() as Array[int]:
		var _player: PlayerInfo = game_info.players.get(id, PlayerInfo.new())
		score_text += "\n%s - %s (id:%s)" % [_player.player_name, game_info.get_wins(id), id]
	score_label.text = score_text
	start_anim()


func end_anim() -> void:
	hide()
	if _game_info:
		_game_info.clear_win_history()
	await get_tree().create_timer(0.5).timeout
	queue_free()
	#if t and t.is_running():
	#t.kill()
	#t = default_tween()
	#for table in all_t:
	#t.tween_property(table, "tween_value", 0.0, 1.5)
