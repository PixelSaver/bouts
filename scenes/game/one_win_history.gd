extends AspectRatioContainer
class_name OneWinHistoryDisplay

@export var inside_panel: Panel
@export var bg_panel: Panel
@export var default_inside_color: Color = Color("403e70")
@export var default_outside_color: Color = Color("615e85ff")
@export var current_round_color: Color = Color(0.565, 0.706, 0.871, 1.0)
var _box: StyleBoxFancy
var _bg_box: StyleBoxFancy


func _ready() -> void:
	_box = inside_panel.get_theme_stylebox("panel").duplicate(true)
	inside_panel.add_theme_stylebox_override("panel", _box)
	_bg_box = bg_panel.get_theme_stylebox("panel").duplicate(true)
	bg_panel.add_theme_stylebox_override("panel", _bg_box)
	_box.color = default_inside_color
	_bg_box.color = default_outside_color


func display(color: Color) -> void:
	if not self.is_node_ready():
		await self.ready
	_box.color = color


func set_as_current_round() -> void:
	if not self.is_node_ready():
		await self.ready
	_bg_box.color = current_round_color


func reset() -> void:
	_box.color = default_inside_color
