extends RichTextLabel
class_name WinNumberLabel

@export var follow_target := Node2D
@export var follow_offset := Vector2.UP * 130.
@export var fade_delay := 3.0
var t : Tween

func _ready() -> void:
	self.modulate.a = 0.0

func flash_wins(wins:int) -> void: 
	self.text = str(wins)
	_fade_tween()

func _process(_delta: float) -> void:
	self.global_position = follow_target.global_position + follow_offset - self.size * 0.5

func _fade_tween():
	self.modulate.a = 1
	if t and t.is_running: t.kill()
	t = create_tween().set_ease(Tween.EASE_IN)
	t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "modulate:a", 0., fade_delay)
