extends Node2D
class_name BulletManager

var bullets: Dictionary[int, Bullet] = {}
var next_id := 0

const BULLET = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	SignalBus.bullet_spawned.connect(spawn_bullet)

#region Spawning bullets
func spawn_bullet(atk:Attack, rot:float, pos:Vector2, owned_id:int) -> void:
	if !multiplayer.is_server(): return
	var id = next_id
	next_id += 1
	var inst = BULLET.instantiate() as Bullet
	inst.net_id = id
	inst.owner_id = owned_id
	inst.attack = atk
	inst.global_position = pos
	inst.global_rotation = rot
	inst.top_level = true
	
	self.add_child(inst)
	bullets.set(id, inst)
	#inst.tree_exiting.connect(func(): bullets.erase(inst))
	spawn_bullet_remote.rpc(id, pos, rot, owned_id)

@rpc("authority", "call_remote")
func spawn_bullet_remote(net_id:int, pos:Vector2, rot:float, owned_id:int):
	var bullet = BULLET.instantiate() as Bullet
	bullet.net_id = net_id
	bullet.owner_id = owned_id
	bullet.global_position = pos
	bullet.global_rotation = rot
	
	add_child(bullet)
	bullets[net_id] = bullet
#endregion

func clear_bullets() -> void:
	for bullet in bullets.values(): 
		bullet.queue_free()

#region Syncing bullets
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	var states = []
	for bullet in (bullets.values() as Array[Bullet]): 
		bullet.global_position += Vector2.RIGHT.rotated(bullet.global_rotation) * delta * bullet.speed
		states.append({
			"id": bullet.net_id,
			"pos": bullet.global_position,
			"rot": bullet.global_rotation,
		})
	sync_projectiles.rpc(states)

@rpc("authority", "call_remote", "unreliable")
func sync_projectiles(states: Array):
	for state in states:
		var bullet = bullets.get(state.id) as Bullet
		if bullet:
			bullet.global_position = state.pos
			bullet.global_rotation = state.rot
#endregion
