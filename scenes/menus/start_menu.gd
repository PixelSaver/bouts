extends PixelMenu
class_name StartMenu

@export var buttons: Array[DefaultButton]
@export var input_name: LineEdit
@export var input_color: ColorPickerButton
var _play_but: ShadowedButton
var all_t: Array[Tweenable] = []


func _ready() -> void:
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))
		if but.name.to_lower() == "play":
			_play_but = but
	Global.menu_manager.gdsync_connection_changed.connect(_on_gdsync_connection_changed)
	if Global.menu_manager.is_gdsync_connected:
		_on_gdsync_connection_changed(true)

	input_name.text_changed.connect(
		func(_x):
			_update_player_info(),
	)
	input_color.color_changed.connect(
		func(_x):
			_update_player_info(),
	)


func _update_player_info() -> void:
	var pi = Global.menu_manager.player_info
	pi.player_name = input_name.text
	pi.color = input_color.color


func _on_gdsync_connection_changed(_is_connected: bool) -> void:
	if _is_connected:
		_play_but.set_button_text("Play")
		_play_but.disabled = false
	else:
		_play_but.set_button_text("Connecting to servers...")
		_play_but.disabled = true


func _on_button_pressed(_name: String) -> void:
	match _name.to_lower():
		"play":
			var scene = SceneDatabase.get_scene(SceneDatabase.Scene.MULTIPLAYER)
			Global.menu_manager.transition_to_scene(scene)
		"settings":
			#TODO Settings / tutorial page
			pass
		"quit":
			pass
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])


func start_anim() -> void:
	pass


func end_anim() -> void:
	queue_free()
