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
	for upgrade in Global.round_state.upgrades:
		var inst = CARD_DISPLAY.instantiate() as CardDisplay
		cards_cont.add_child(inst)
		inst.card_info = UpgradeManager.get_card_info(upgrade)
		inst.set_multiplayer_authority(lost_id)
		inst.update_mouse_filter()
	
func end_anim() -> void: 
	pass
