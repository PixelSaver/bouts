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
	if Global.players_lost.size() == 0:
		push_error("no one lost...")
		return
	#TODO Implement 4 player here
	var lost_id = Global.players_lost.front()
	
	set_multiplayer_authority(lost_id)
	for child in cards_cont.get_children():
		child.queue_free()
	var upgrades = UpgradeManager.get_random_upgrades(init_cards_amount)
	for upgrade in upgrades:
		var inst = CARD_DISPLAY.instantiate() as CardDisplay
		cards_cont.add_child(inst)
		inst.card_info = UpgradeManager.get_card_info(upgrade)
	for card in _get_cards():
		card.set_multiplayer_authority(lost_id)
		card.mouse_filter = Control.MOUSE_FILTER_PASS if is_multiplayer_authority() else Control.MOUSE_FILTER_IGNORE
	
func end_anim() -> void: 
	pass
