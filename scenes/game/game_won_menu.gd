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


func _on_but_pressed(but_name: String) -> void:
	match but_name.to_lower():
		"backtolobby":
			Global.menu_manager.transition_to_scene(
				SceneDatabase.get_scene(SceneDatabase.Scene.MULTIPLAYER)
			)
		"nextgame":
			_game_info.clear_game_history()
			var game_menu: GameMenu = Global.menu_manager.transition_to_scene(
				SceneDatabase.get_scene(SceneDatabase.Scene.GAME)
			)
			game_menu.pass_game_info(_game_info)


func start_anim() -> void:
	if not _game_info:
		return
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		table.tween_value = 0.
		t.tween_property(table, "tween_value", 1.0, 5.5)


func pass_game_info(game_info: GameInfo) -> void:
	_game_info = game_info
	var winner_id := _game_info.get_game_winner()
	var winner_pi: PlayerInfo = _game_info.players.get(winner_id, PlayerInfo.new())
	winner_label.text = "%s Wins (Player #%s)" % [
		winner_id,
		winner_pi.player_name,
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
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 0.0, 1.5)
