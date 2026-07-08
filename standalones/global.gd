extends Node

enum States {
	START,
}
var state : States = States.START

var menu_manager: MultiplayerManager

#var multiplayer_manager: MultiplayerManager

var player_won_id := -1
var players_lost : Array[int] = []
