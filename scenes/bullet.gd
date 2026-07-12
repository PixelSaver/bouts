extends Area2D
class_name Bullet

@onready var trail: Line2D = $Trail

@export var attack: Attack
@export var speed := 1000
@export var bullet_gravity := 10.
@export var drag := 0.9
@export var trail_length := 10
var owner_id : int
var net_id : int
var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var prev_pos : Array[Vector2] = []


#@rpc("any_peer", "call_remote")
#func sync_location(pos:Vector2):
	#if not multiplayer.is_server(): return
	#self.global_position = pos

func server_update(delta: float) -> void: 
	velocity += acceleration * delta
	global_position += velocity * delta
	prev_pos.append(self.global_position)
	_update_trail()
func _update_trail():
	trail.clear_points()
	if prev_pos.size() > trail_length:
		prev_pos.pop_front()
	for p in prev_pos:
		trail.add_point(p)


func _body_entered(body:Node2D) -> void:
	if not multiplayer.is_server(): return
	if body is not Player: return
	## Check that the bullet isnt hitting it's own parent
	if body.get_multiplayer_authority() == owner_id: return
	var player = body as Player
	player.damage(attack)
