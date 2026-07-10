extends PixelMenu
class_name CardsScreen

@export var cards_cont: CardsContainer
const CARD_DISPLAY := preload("res://scenes/game/card_display.tscn")
var init_cards_amount := 5

func _get_cards() -> Array[CardDisplay]:
	var out : Array[CardDisplay] = []
	for child in cards_cont.get_children():
		out.append(child)
	return out

func _ready() -> void:
	pass
func start_anim() -> void: 
	if Global.player_won_id == -1: 
		push_error("Tied or winning player id was -1")
		return
	#TODO Implement 4 player here
	var lost_id = Global.get_losers().front()
	if not lost_id: 
		push_error("No id from losers... tie?")
		return
	
	set_multiplayer_authority(lost_id)
	for child in cards_cont.get_children():
		child.queue_free()
	for upgrade in Global.round_state.player_states.values().front():
		var inst = CARD_DISPLAY.instantiate() as CardDisplay
		cards_cont.add_child(inst)
		inst.card_info = UpgradeManager.get_card_info(upgrade)
		inst.set_multiplayer_authority(lost_id)
		inst.update_mouse_filter()
		inst.pressed.connect(_on_card_pressed.bind(upgrade))

func _on_card_pressed(upgrade:UpgradeManager.Upgrades):
	submit_upgrade_pick.rpc_id(1, upgrade)
@rpc("any_peer", "reliable")
func submit_upgrade_pick(upgrade:UpgradeManager.Upgrades):
	if not multiplayer.is_server(): return
	var sender := multiplayer.get_remote_sender_id()
	if not Global.round_state.player_states.keys().has(sender) or not Global.round_state.player_states.get(sender, []).has(upgrade): 
		push_warning("Server doesn't have client picked upgrade in possible upgrades")
		return
	receive_upgrade.rpc(sender, upgrade)
@rpc("authority", "call_remote", "reliable")
func receive_upgrade(player_id:int, upgrade:UpgradeManager.Upgrades):
	var pi: PlayerInfo = Global.menu_manager.players.get(player_id)
	if not pi: 
		push_warning("Playerid not found when upgrading ")
	pi.upgrades.append(upgrade)
	

func end_anim() -> void: 
	pass
