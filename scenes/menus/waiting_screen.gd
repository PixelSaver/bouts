extends PixelMenu
class_name WaitingScreen

@export var player_list_text: RichTextLabel

func _ready() -> void: 
	player_list_text.clear()

func _process(_delta: float):
	player_list_text.clear()
	#player_list_text.append_text("[font_size=70]")
	var keys = Global.menu_manager.players.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var player_info: PlayerInfo = Global.menu_manager.players.get(key)
		if not player_info: 
			printerr("Player info not readable as PlayerInfo")
			continue
		player_list_text.append_text("Player #%s: <%s>\n" % [i, player_info])

func start_anim() -> void: 
	show()
func end_anim() -> void: 
	hide()
