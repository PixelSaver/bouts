extends RefCounted
class_name LobbyInfo
## LobbyInfo holds the information about a lobby.

@export var lobby_name: String = ""
@export var lobby_player_count: int = 0
@export var lobby_player_limit: int = 2
@export var lobby_is_public: bool = true
@export var lobby_is_open: bool = true
@export var lobby_tags: Dictionary = { }
@export var lobby_has_password: bool = false
@export var lobby_web_only: bool = false
#@export var lobby_host: RefCounted = null

#static func from_params()


static func from_dict(dict: Dictionary) -> LobbyInfo:
	var lobby = LobbyInfo.new()
	lobby.lobby_name = dict.get("Name", "")
	lobby.lobby_player_count = dict.get("PlayerCount", 0)
	lobby.lobby_player_limit = dict.get("PlayerLimit", 2)
	lobby.lobby_is_public = dict.get("Public", true)
	lobby.lobby_is_open = dict.get("Open", true)
	lobby.lobby_tags = dict.get("Tags", { })
	lobby.lobby_has_password = dict.get("HasPassword", false)
	lobby.lobby_web_only = dict.get("WebOnly", false)
	#lobby.lobby_is_host = dict.get("Host", false)
	return lobby


func to_dict() -> Dictionary:
	return {
		"Name": lobby_name,
		"PlayerCount": lobby_player_count,
		"PlayerLimit": lobby_player_limit,
		"Public": lobby_is_public,
		"Open": lobby_is_open,
		"Tags": lobby_tags,
		"HasPassword": lobby_has_password,
		"WebOnly": lobby_web_only,
		#"Host": lobby_is_host,
	}
