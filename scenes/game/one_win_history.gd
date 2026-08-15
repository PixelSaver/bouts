extends AspectRatioContainer
class_name OneWinHistoryDisplay

@export var inside_panel: Panel
@export var default_inside_color: Color = Color("403e70")
var _box: StyleBoxFancy


func _ready() -> void:
	_box = inside_panel.get_theme_stylebox("panel").duplicate(true)
	inside_panel.add_theme_stylebox_override("panel", _box)


func display(color: Color) -> void:
	if not self.is_node_ready():
		await self.ready
	_box.color = color


func reset() -> void:
	_box.color = default_inside_color
