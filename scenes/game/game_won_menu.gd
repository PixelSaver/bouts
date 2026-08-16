extends PixelMenu
class_name GameWonMenu

@export var buttons: Array[DefaultButton]
@export var winner_label: RichTextLabel
@export var score_label: RichTextLabel
var all_t: Array[Tweenable] = []
var t: Tween
var _game_info: GameInfo


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	all_t = get_all_tweenables(self)


func start_anim() -> void:
	if not _game_info:
		return
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 1.0, 1.5)


func pass_game_info(game_info: GameInfo) -> void:
	_game_info = game_info
	var winner_id := _game_info.get_game_winner()
	winner_label.text = "%s Wins (Player #%s)" % [
		winner_id,
		(_game_info.players.get(winner_id, PlayerInfo.new()) as PlayerInfo).player_name,
	]
	start_anim()


func end_anim() -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 0.0, 1.5)
