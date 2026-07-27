extends MarginContainer

@export var player: Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_disable(Player.DisableMode.FROZEN)
	SignalBus.player_info_changed.connect(_on_pi_changed)


func _on_pi_changed(pi: PlayerInfo) -> void:
	player.set_color(pi.color)
	#TODO Add player weapon to the display
