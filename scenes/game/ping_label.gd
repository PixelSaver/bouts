extends Label

var _cooldown = 1.


func _ready() -> void:
	if not OS.is_debug_build():
		self.queue_free()


func _process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown < 0:
		_cooldown = 1.0
		var p = await GDSync.get_client_ping(GDSync.get_client_id())
		var pp = await GDSync.get_client_perceived_ping(GDSync.get_client_id())
		self.text = "Ping: %s, Perceived Ping: %s" % [p, pp]
