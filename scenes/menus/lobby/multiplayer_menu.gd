extends PixelMenu
class_name MultiplayerMenu
@export_group("Loading", "loading_")
@export var loading_screen: PixelMenu
#@export var status_text: RichTextLabel
@export var loading_ip: LineEdit
@export var loading_host_button: Button
@export var loading_join_button: Button
@export_group("Waiting", "waiting_")
@export var waiting_screen: PixelMenu
@export var waiting_start_game_button: DefaultButton

func _ready() -> void: 
	loading_host_button.pressed.connect(func(): 
		SignalBus.host.emit()
	)
	loading_join_button.pressed.connect(func(): SignalBus.join.emit(loading_ip.text))
	loading_screen.show()
	waiting_screen.hide()
	SignalBus.hosted.connect(_on_hosted)
	waiting_start_game_button.pressed.connect(_on_start_game)

func _on_start_game() -> void:
	start_game.rpc()

@rpc("authority","call_local")
func start_game():
	Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.GAME))

func _on_hosted() -> void: 
	loading_screen.end_anim()
	waiting_screen.start_anim()

func start_anim() -> void: 
	loading_screen.start_anim()
func end_anim() -> void: 
	queue_free()
