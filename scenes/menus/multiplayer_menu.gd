extends PixelMenu
class_name MultiplayerMenu
@export_group("Loading", "loading_")
@export var loading_screen: PixelMenu
#@export var status_text: RichTextLabel
@export var name_ip: LineEdit
@export var color_ip: ColorPickerButton
@export var loading_ip: LineEdit
@export var loading_host_button: Button
@export var loading_join_button: Button
@export_group("Waiting", "waiting_")
@export var waiting_screen: PixelMenu
@export var waiting_start_game_button: DefaultButton

func _ready() -> void: 
	loading_host_button.pressed.connect(_on_hosted)
	loading_join_button.pressed.connect(_on_join.bind(loading_ip.text))
	name_ip.text_changed.connect(_update_player_info)
	color_ip.color_changed.connect(_update_player_info)
	loading_screen.show()
	waiting_screen.hide()
	SignalBus.hosted.connect(_on_hosted)
	#SignalBus.join.connect(_on_join)
	waiting_start_game_button.pressed.connect(_on_start_game)

func _on_start_game() -> void:
	start_game.rpc()

@rpc("authority", "call_local")
func start_game():
	Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.GAME))

func _on_hosted() -> void: 
	_update_player_info()
	loading_screen.end_anim()
	waiting_screen.start_anim()
	SignalBus.host.emit()
func _on_join(_ip:String) -> void:
	_update_player_info()
	SignalBus.join.emit(loading_ip.text)
	loading_screen.end_anim()
	waiting_screen.start_anim()
func _update_player_info() -> void:
	var p_info = Global.menu_manager.player_info
	if not p_info.player_name.is_empty(): p_info.player_name = name_ip.name
	p_info.color = color_ip.color
	SignalBus.player_info_changed.emit(p_info)
func start_anim() -> void: 
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	loading_screen.start_anim()
func end_anim() -> void: 
	queue_free()
