extends Area2D
class_name Bullet

@export var attack: Attack
@export var speed := 100
var owner_id : int
var net_id : int



#@rpc("any_peer", "call_remote")
#func sync_location(pos:Vector2):
	#if not multiplayer.is_server(): return
	#self.global_position = pos

func server_update(delta: float) -> void: pass
	#if multiplayer.is_server() and is_inside_tree(): self.sync_location.rpc(self.global_position)


func _body_entered(body:Node2D) -> void:
	if body is not Player: return
	if body.get_multiplayer_authority() == owner_id: return
	var player = body as Player
	player.damage(attack)
