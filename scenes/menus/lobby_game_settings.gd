extends Panel
class_name LobbyGameSettings

@export var round_type_button: OptionButton
@export var max_rounds_slider: HSlider
@export var slider_label: RichTextLabel


func _ready() -> void:
	for key in GameInfo.RoundType.keys() as Array[String]:
		round_type_button.add_item(key.capitalize())
	round_type_button.item_selected.connect(_on_round_type_button)
	max_rounds_slider.changed.connect(_on_slider)
	_update_slider_label()
	GDSync.host_changed.connect(_update_visibility)
	SignalBus.joined.connect(_update_visibility)
	_update_visibility()


func _update_visibility(_x = null) -> void:
	self.visible = GDSync.is_host()
	Log.pr("Tested visibliity, %s" % self.visible)


func _update_slider_label() -> void:
	slider_label.text = str(max_rounds_slider.value)


func _on_round_type_button(idx: int) -> void:
	Global.menu_manager.game_info.change_game_settings(idx, -1)


func _on_slider() -> void:
	var new_max_rounds := int(roundf(max_rounds_slider.value))
	Global.menu_manager.game_info.change_game_settings(-1, new_max_rounds)
	_update_slider_label()
