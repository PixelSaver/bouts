extends MarginContainer

@export var player: Player
@export var color_picker_button: ColorPickerButton
@export var weapon_button: OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_disable(Player.DisableMode.NOTHING)
	Global.menu_manager.game_info.player_info_changed.connect(_on_pi_changed)
	_on_pi_changed(GDSync.get_client_id(), Global.menu_manager.player_info)
	for w_name in WeaponManager.get_all_weapon_types_str():
		weapon_button.add_item(w_name)
	weapon_button.item_selected.connect(_on_item_selected)
	color_picker_button.color_changed.connect(_on_color_selected)


func _on_item_selected(index: int) -> void:
	var weapon_type = index as WeaponManager.WeaponType
	#weapon_chosen.emit(weapon_type)
	Global.menu_manager.player_info.weapon = weapon_type
	player.bind_weapon(weapon_type)


func _on_color_selected(color: Color) -> void:
	var pi = Global.menu_manager.player_info
	pi.color = color
	Global.menu_manager.game_info.pi_change_func(pi, pi.id)


func _on_pi_changed(id: int, pi: PlayerInfo) -> void:
	if id != GDSync.get_client_id():
		return
	color_picker_button.color = pi.color
	player.set_color(pi.color)
	player.bind_weapon(pi.weapon)
#TODO Add player weapon to the display
