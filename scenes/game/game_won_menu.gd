extends PixelMenu
class_name GameWonMenu

@export var buttons: Array[DefaultButton]
var all_t: Array[Tweenable] = []
var t: Tween


func _ready() -> void:
	all_t = get_all_tweenables(self)


func start_anim() -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 1.0, 1.5)


func end_anim() -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 0.0, 1.5)
