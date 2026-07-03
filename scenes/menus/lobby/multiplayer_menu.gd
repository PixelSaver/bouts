extends PixelMenu
class_name MultiplayerMenu
@export_group("Loading", "loading_")
@export var loading_screen: PixelMenu
#@export var status_text: RichTextLabel
@export var loading_ip: LineEdit
@export var loading_host_button: Button
@export var loading_join_button: Button
@export_group("Host Waiting", "host_waiting_")
@export var host_waiting_screen: PixelMenu
@export_group("Client Waiting", "client_waiting")
@export var client_waiting_screen: PixelMenu

func _ready() -> void: 
	loading_host_button.pressed.connect(func(): 
		SignalBus.host.emit()
	)
	loading_join_button.pressed.connect(func(): SignalBus.join.emit(loading_ip.text))
	loading_screen.show()
	host_waiting_screen.hide()
	client_waiting_screen.hide()
	SignalBus.hosted.connect(_on_hosted)

func _on_hosted() -> void: 
	loading_screen.end_anim()
	host_waiting_screen.start_anim()

func start_anim() -> void: 
	loading_screen.start_anim()
func end_anim() -> void: pass
