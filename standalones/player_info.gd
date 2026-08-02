extends Resource
class_name PlayerInfo

signal info_changed(new_info: PlayerInfo)
@export var player_name = "":
	set(val):
		player_name = val
		info_changed.emit(self)
@export var id = 0:
	set(val):
		id = val
		info_changed.emit(self)
@export var color = Color.WHITE:
	set(val):
		color = val
		info_changed.emit(self)
@export var is_host := false:
	set(val):
		is_host = val
		info_changed.emit(self)


func _init(_name: String = "") -> void:
	player_name = _name if _name.length() > 0 else "PlayerName"
	GDSync.host_changed.connect(_on_host_changed)


func force_update_host() -> void:
	self.is_host = GDSync.is_host()


func _on_host_changed(new_is_host: bool, _new_host_id: int) -> void:
	self.is_host = new_is_host


func to_dict() -> Dictionary:
	return { "player_name": player_name, "color": color, "id": id, "is_host": is_host }


static func from_dict(d: Dictionary) -> PlayerInfo:
	var p = PlayerInfo.new()
	p.player_name = d.get("player_name", "PlayerName")
	p.color = d.get("color", Color.WHITE)
	p.id = d.get("id", 0)
	p.is_host = d.get("is_host", false)
	return p


func _to_string() -> String:
	return "PlayerInfo Res (ID: %s, Name: %s, Color: %s)" % [self.id, self.player_name, self.color]
