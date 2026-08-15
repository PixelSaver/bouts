extends HBoxContainer
class_name WinHistoryDisplay

const WIN_DISPLAY = preload("res://scenes/game/one_win_history.tscn")


func _ready() -> void:
	SignalBus.round_started.connect(_on_round_started)


func _clear_history_display() -> void:
	for child in get_children(true):
		child.queue_free()


func _on_round_started(gi: GameInfo) -> void:
	Log.pr("Started received, win history: %s" % str(gi.win_history))
	_clear_history_display()
	await get_tree().create_timer(1.0).timeout
	for id in gi.win_history:
		var inst = WIN_DISPLAY.instantiate() as OneWinHistoryDisplay
		if id <= 0:
			inst.reset()
			return
		inst.display((gi.players.get(id, PlayerInfo.new()) as PlayerInfo).color)
		add_child(inst)

	var curr = WIN_DISPLAY.instantiate() as OneWinHistoryDisplay
	curr.set_as_current_round()
	add_child(curr)
