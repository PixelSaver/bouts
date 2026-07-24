extends PixelMenu
class_name AuthMenu

var t: Tween


func _ready() -> void:
	self.hide()
	self.offset_transform_enabled = true
	self.offset_transform_pivot_ratio = Vector2(0.0, -1.0)


func start_anim() -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	self.show()
	t.tween_property(self, "offset_transform_position_ratio", Vector2(0.0, 0.0), 0.7)
	t.tween_property(self, "modulate:a", 1.0, 0.7)
	Log.pr("Starting anim for %s" % self.name)


func end_anim() -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	self.hide()
	t.tween_property(self, "offset_transform_position_ratio", Vector2(0.0, -1.0), 0.7)
	t.tween_property(self, "modulate:a", 0.0, 0.7)
	Log.pr("Ending anim for %s" % self.name)
