@tool
extends DefaultButton

@onready var panel: Panel = $Panel
@export var shadow_range := Vector2(5, 15)
@export var shadow_direction := Vector2(1,1)
var box : StyleBox

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	if panel: 
		box = panel.get_theme_stylebox("panel").duplicate()
		box.shadow_offset = Vector2(5,5)
		panel.add_theme_stylebox_override("panel", box)

func _hover() -> void:
	if Engine.is_editor_hint(): return
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.7)
	if panel and box.get("shadow_offset") != null:
		t.tween_property(box, "shadow_offset", shadow_direction * shadow_range.y, 0.7)
	
func _unhover() -> void:
	if Engine.is_editor_hint(): return
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.7)
	if panel and box.get("shadow_offset") != null:
		t.tween_property(box, "shadow_offset", shadow_direction * shadow_range.x, 0.7)
