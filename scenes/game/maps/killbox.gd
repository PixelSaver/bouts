extends Area2D
class_name KillBox


func _on_body_entered(body: Node2D) -> void:
	var par = body.get_parent()
	if par is not Player:
		return
	var player = par as Player
	Log.pr("Found player")
	#TODO Add knockback and livability to the killbox maybe?
	var atk = Attack.new()
	atk.damage = 100.
	player.damage(atk)
