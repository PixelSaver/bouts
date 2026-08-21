extends Node2D
class_name ProjectileManager

enum ProjectileType {
	DEFAULT,
}
var projectile_scenes: Dictionary[ProjectileType, PackedScene] = {
	ProjectileType.DEFAULT: preload("res://scenes/weapons/projectiles/generic_bullet.tscn")
}
var projectiles: Dictionary[int, Projectile] = { }


func _ready() -> void:
	SignalBus.projectile_spawn_requested.connect(_on_proj_spawn_requested)
	GDSync.expose_func(_spawn_proj)


func _on_proj_spawn_requested(
	p_type: ProjectileType,
	atk: Attack,
	rot: float,
	pos: Vector2,
	owned_id: int,
):
	if not GDSync.is_host():
		return
	var id = get_next_projectile_id(owned_id)
	GDSync.call_func_all(_spawn_proj, p_type, atk.to_dict(), rot, pos, owned_id, id)


func _spawn_proj(
	p_type: ProjectileType,
	atk_d: Dictionary,
	rot: float,
	pos: Vector2,
	owned_id: int,
	name_id: int,
):
	var atk = Attack.from_dict(atk_d)
	var p = projectile_scenes.get(p_type).instantiate() as Projectile
	p.attack = atk
	p.global_rotation = rot
	p.global_position = pos
	p.owner_id = owned_id
	p.name = "Projectile_%d" % name_id
	add_child(p)
	SignalBus.projectile_spawned.emit(p, owned_id)


func get_next_projectile_id(owner_id: int) -> int:
	return owner_id * 10000 + projectiles.size() % 100 * 100 + randi_range(0, 99)


func register_projectile(p: Projectile, id: int) -> void:
	projectiles.set(id, p)
	p.name = "Projectile_%s" % id
	add_child(p)


func _physics_process(delta: float) -> void:
	for id in projectiles.keys():
		var p = projectiles.get(id) as Projectile
		p.process_projectile_movement(delta)
