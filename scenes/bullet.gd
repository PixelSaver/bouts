extends Area2D
class_name Bullet

@export var attack: Attack
@export var speed := 100

const BULLET = preload("res://scenes/bullet.tscn")

@rpc("authority", "call_local")
static func spawn_bullet(atk:Attack, rot:float, pos:Vector2) -> Bullet:
	var inst = BULLET.instantiate() as Bullet
	inst.attack = atk
	inst.global_position = pos
	inst.global_rotation = rot
	return inst

@rpc("any_peer", "call_remote")
func sync_location(pos:Vector2):
	if not multiplayer.is_server(): return
	self.global_position = pos

func _physics_process(delta: float) -> void:
	self.global_position += Vector2.RIGHT.rotated(self.global_rotation) * delta * speed
	if multiplayer.is_server(): self.sync_location.rpc(self.global_position)

func _body_entered(body:Node2D) -> void:
	if body is not Player: return
	var player = body as Player
	player.damage(attack)
