extends PixelMenu
class_name HostWaitingScreen

@export var player_list_text: RichTextLabel

func _ready() -> void: 
	Global.menu_manager.player_connected.connect(_on_players_changed)

func _on_players_changed(_ip:int, _pi:PlayerInfo):
	await get_tree().process_frame
	player_list_text.clear()
	#player_list_text.append_text("[font_size=70]")
	for key in Global.menu_manager.players.keys():
		var player_info: PlayerInfo = Global.menu_manager.players.get(key)
		if not player_info: 
			printerr("Player info not readable as PlayerInfo")
			continue
		player_list_text.append_text("%s\n" % player_info)

func start_anim() -> void: 
	show()
func end_anim() -> void: 
	hide()
