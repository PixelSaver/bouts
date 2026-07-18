extends RigidBody2D

@export var damage := 10

func _body_entered(body:Node) -> void:
	if body is not Player: return
	var player = body as Player
	var atk = Attack.new()
	atk.damage = damage
	player.damage(atk)
