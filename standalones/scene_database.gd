extends Node

const DEFAULT_SCENE = Scene.GAME
enum Scene {
	START,
	MULTIPLAYER,
	GAME,
	CARDS,
}

var scenes = {
	Scene.START: preload("res://scenes/menus/start_screen.tscn"),
	Scene.GAME: preload("res://scenes/game/game_menu.tscn"),
	Scene.MULTIPLAYER: preload("res://scenes/menus/multiplayer_menu.tscn"),
}
func get_scene(scene:Scene) -> PackedScene:
	if scenes.has(scene):
		return scenes.get(scene)
	else: 
		print("Failed to get scene #(%s), returning scene#(%s)" % [scene, DEFAULT_SCENE])
		return scenes.get(DEFAULT_SCENE)
