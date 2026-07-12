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
	print("Upgrade: %s" % upgrade)
	if multiplayer.is_server():
		submit_upgrade_pick(upgrade)
	else:
		submit_upgrade_pick.rpc_id(1, upgrade)
@rpc("any_peer", "reliable")
## Client rpc's server to tell it what upgrade it wants
func submit_upgrade_pick(upgrade:UpgradeManager.Upgrades):
	if not multiplayer.is_server(): return
	var sender := multiplayer.get_remote_sender_id()
	sender = 1 if sender == 0 else sender
	if not Global.round_state.player_states.keys().has(sender) or not Global.round_state.player_states.get(sender, []).has(upgrade): 
		push_warning("Server doesn't have client picked upgrade in possible upgrades")
		return
	receive_upgrade.rpc(sender, upgrade)
@rpc("any_peer", "call_local", "reliable")
## Server rpc's all clients to tell what upgrades it gave
func receive_upgrade(player_id:int, upgrade:UpgradeManager.Upgrades):
	var pi: PlayerInfo = Global.menu_manager.players.get(player_id)
	if not pi: 
		push_warning("Playerid not found when upgrading ")
	pi.upgrades.append(upgrade)
	if multiplayer.is_server():
		await card_selection_anim()
		receive_move_on.rpc()

@rpc("any_peer", "call_local", "reliable")
func receive_move_on():
	Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.GAME))

func card_selection_anim():
	#TODO Add the card selection animation
	await get_tree().process_frame

func end_anim() -> void: 
	self.hide()
	for card in _get_cards():
		card.syncing = false
	await get_tree().create_timer(2.0).timeout
	queue_free()
