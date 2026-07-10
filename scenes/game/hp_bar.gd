extends TextureProgressBar
class_name HPBar

@export var fade_delay := 3.0
var t : Tween

func _ready() -> void:
	self.modulate.a = 0.0

func _on_health_component_health_changed(health: Variant, max_health: Variant) -> void:
	self.value = health
	if max_health != max_value: self.max_value = max_health
	_fade_tween()

func _fade_tween():
	self.modulate.a = 1
	if t and t.is_running: t.kill()
	t = create_tween().set_ease(Tween.EASE_IN)
	t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "modulate:a", 0., fade_delay)
