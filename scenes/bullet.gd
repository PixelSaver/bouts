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



func _physics_process(delta: float) -> void:
	self.global_position += Vector2.RIGHT.rotated(self.global_rotation) * delta * speed

func _body_entered(body:Node2D) -> void:
	if body is not Player: return
	var player = body as Player
	player.damage(attack)
