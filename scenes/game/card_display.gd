extends Panel
class_name CardDisplay

@export_group("Display", "display_")
@export var display_name: RichTextLabel
@export var display_icon: TextureRect
@export var display_desc: RichTextLabel
@export var card_info:CardInfo :
	set(val):
		card_info = val
		display_card_info(val)
var syncing := false

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	syncing = true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			pass
		NOTIFICATION_MOUSE_EXIT:
			pass

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		if syncing: sync_location.rpc(self.offset_transform_position)
	update_mouse_filter()

func update_mouse_filter():
	self.mouse_filter = Control.MOUSE_FILTER_PASS if is_multiplayer_authority() else Control.MOUSE_FILTER_IGNORE

@rpc("authority", "call_remote", "unreliable")
func sync_location(pos:Vector2):
	self.offset_transform_position = pos

func display_card_info(_card_info: CardInfo):
	self.display_name.text = _card_info.name
	self.display_icon.texture = _card_info.icon
	self.display_desc.text = _card_info.description
