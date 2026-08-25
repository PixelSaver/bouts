extends Control
class_name GameUI

@export var skill_progress: TextureProgressBar
var _max_countdown := 0.


func _ready() -> void:
	SignalBus.player_skill_cooldown_changed.connect(_on_skill_cooldown_changed)


func _on_skill_cooldown_changed(countdown: int, max_countdown: int) -> void:
	skill_progress.value = max_countdown - countdown
	skill_progress.max_value = max_countdown
	_max_countdown = max_countdown
	Log.pr("Skil cooldown received fully")


func _process(delta: float) -> void:
	skill_progress.value = skill_progress.value + delta
