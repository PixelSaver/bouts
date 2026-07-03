extends Resource
class_name PlayerInfo

@export var player_name = ""
@export var id = 0
@export var color = Color.WHITE
@export var is_host := false

func _init(_name: String="") -> void:
	player_name = _name if _name.length() > 0 else "PlayerName"

func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"color": color,
		"is_host": is_host,
		"id": id,
	}
static func from_dict(d: Dictionary) -> PlayerInfo:
	var p = PlayerInfo.new()
	p.player_name = d.get("player_name", "PlayerName")
	p.color = d.get("color", Color.WHITE)
	p.is_host = d.get("is_host", false)
	p.id = d.get("id", 0)
	return p

func _to_string() -> String:
	return "PlayerInfo Res (Name: %s, Color: %s, is host? %s)" % [self.player_name, self.color, self.is_host]
