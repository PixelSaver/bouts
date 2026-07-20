extends Resource
class_name PlayerInfo

@export var player_name = ""
@export var id = 0
@export var color = Color.WHITE

func _init(_name: String="") -> void:
	player_name = _name if _name.length() > 0 else "PlayerName"

func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"color": color,
		"id": id,
	}
static func from_dict(d: Dictionary) -> PlayerInfo:
	var p = PlayerInfo.new()
	p.player_name = d.get("player_name", "PlayerName")
	p.color = d.get("color", Color.WHITE)
	p.id = d.get("id", 0)
	return p

func _to_string() -> String:
	return "PlayerInfo Res (ID: %s, Name: %s, Color: %s)" % [self.id, self.player_name, self.color]
