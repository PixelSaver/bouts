extends Node2D
class_name ProjectileManager

enum ProjectileType {
	DEFAULT,
	GENERIC_BULLET,
	SNIPER_BULLET,
}
var projectile_scenes: Dictionary[ProjectileType, PackedScene] = {
	ProjectileType.DEFAULT: preload("res://scenes/weapons/projectiles/generic_bullet.tscn"),
	ProjectileType.GENERIC_BULLET: preload("res://scenes/weapons/projectiles/generic_bullet.tscn"),
	ProjectileType.SNIPER_BULLET: preload("res://scenes/weapons/projectiles/sniper_bullet.tscn"),
}
var projectiles: Dictionary[int, Projectile] = { }


func _ready() -> void:
	SignalBus.projectile_spawn_requested.connect(_on_proj_spawn_requested)
	SignalBus.unregister_projectile_requested.connect(unregister_projectile)
	GDSync.expose_func(_spawn_proj)
	GDSync.expose_func(end_projectile)
	GDSync.expose_func(receive_states)


func _on_proj_spawn_requested(
	p_type: ProjectileType,
	atk: Attack,
	rot: float,
	pos: Vector2,
	linear_velocity: Vector2,
	owned_id: int,
):
	if not GDSync.is_host():
		return
	var id = get_next_projectile_id(owned_id)
	GDSync.call_func_all(
		_spawn_proj,
		p_type,
		atk.to_dict(),
		rot,
		pos,
		linear_velocity,
		owned_id,
		id,
	)


func _spawn_proj(
	p_type: ProjectileType,
	atk_d: Dictionary,
	rot: float,
	pos: Vector2,
	linear_velocity: Vector2,
	owned_id: int,
	name_id: int,
):
	var atk = Attack.from_dict(atk_d)
	var p = projectile_scenes.get(p_type).instantiate() as Projectile
	p.attack = atk
	p.global_rotation = rot
	p.global_position = pos
	p.linear_velocity = linear_velocity
	p.owner_id = owned_id
	p.name = "Projectile_%d" % name_id
	self.register_projectile(p, name_id)
	SignalBus.projectile_spawned.emit(p, owned_id)


func get_next_projectile_id(owner_id: int) -> int:
	return owner_id * 10000 + projectiles.size() % 100 * 100 + randi_range(0, 99)


func register_projectile(p: Projectile, id: int) -> void:
	projectiles.set(id, p)
	p.name = "Projectile_%s" % id
	add_child(p)


func unregister_projectile(p: Projectile) -> void:
	var id = projectiles.find_key(p)
	Log.pr("Projectile key is %s" % id)
	if id == null:
		return
	Log.pr("Unregisterable projectile found")
	GDSync.call_func_all(end_projectile, id)


func end_projectile(id: int) -> void:
	var p = projectiles.get(id)
	if not p:
		return
	Log.pr("Ending projectile id %s on client %s" % [id, GDSync.get_client_id()])
	projectiles.erase(id)
	p.queue_free()


func _physics_process(delta: float) -> void:
	for id in projectiles.keys():
		var p = projectiles.get(id) as Projectile
		p.process_projectile_movement(delta)
	if not GDSync.is_host():
		return
	var states: Dictionary[int, Array] = { }
	for id in projectiles.keys():
		var p = projectiles.get(id) as Projectile
		var s = ProjectileState.get_state(p)
		states.set(id, s)
	GDSync.call_func(receive_states, states)


func receive_states(states: Dictionary[int, Array]) -> void:
	for id in states.keys():
		var p = projectiles.get(id) as Projectile
		if not p:
			Log.err("Projectile of id %s not found" % id)
		var s = states.get(id)
		ProjectileState.set_state(s, p)
