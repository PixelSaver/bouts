extends Area2D
class_name KillBox


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var player = body as Player
	#TODO Add knockback and livability to the killbox maybe?
	var atk = Attack.new()
	atk.damage = 100.
	player.damage(atk)
