extends Panel
class_name LobbyGameSettings

@export var round_type_button: OptionButton
@export var max_rounds_slider: HSlider
@export var slider_label: RichTextLabel
var _game_info: GameInfo


func _ready() -> void:
	for key in GameInfo.RoundType.keys() as Array[String]:
		round_type_button.add_item(key.capitalize())
	round_type_button.item_selected.connect(_on_round_type_button)
	max_rounds_slider.value_changed.connect(_on_slider)
	_update_slider_label()
	GDSync.host_changed.connect(
		func(_x, _y):
			_update_visibility(),
	)
	SignalBus.joined.connect(_update_visibility)
	GDSync.lobby_joined.connect(_update_visibility)
	_update_visibility()
	_game_info = Global.menu_manager.game_info
	#_game_info.data_changed.connect(_on_game_info_changed)


func _process(_delta: float) -> void:
	if GDSync.is_host():
		return
	_game_info = Global.menu_manager.game_info
	max_rounds_slider.set_value_no_signal(_game_info.rounds_out_of)
	round_type_button.select(_game_info.round_type)
	_update_slider_label()


func _update_visibility(_x = null) -> void:
	self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED if GDSync.is_host() else Control.MOUSE_BEHAVIOR_DISABLED
	Log.pr("Tested visibliity, %s" % self.visible)


func _update_slider_label() -> void:
	slider_label.text = "%d" % (max_rounds_slider.value)


func _on_round_type_button(idx: int) -> void:
	Global.menu_manager.game_info.change_game_settings(idx, -1)


func _on_slider(value: float) -> void:
	var new_max_rounds := int(value)
	Global.menu_manager.game_info.change_game_settings(-1, new_max_rounds)
	_update_slider_label()
