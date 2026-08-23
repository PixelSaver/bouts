extends Weapon
class_name Sniper

@export var colliding_bodies: Array[Projectile]
@export var marker: Marker2D
var bullet_occlusion_range: float = 1000.


func _ready() -> void:
	self.set_meta("is_weapon", true)
	SignalBus.projectile_spawned.connect(_on_proj_spawned)
	bullet_occlusion_range = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2


func _on_proj_spawned(p: Projectile, owner_id: int):
	if not player:
		return
	if GDSync.get_gdsync_owner(player) != owner_id:
		return
	colliding_bodies.append(p)
	p.owner_player = player
	p.tree_exiting.connect(_erase_p.bind(p))


func _erase_p(p: Projectile) -> void:
	colliding_bodies.erase(p)


func apply_skill(_player: Player = player) -> void:
	Log.pr("Gun shooting")
	var atk = Attack.new()
	atk.damage = 1.0
	SignalBus.projectile_spawn_requested.emit(
		ProjectileManager.ProjectileType.SNIPER_BULLET,
		atk,
		marker.global_rotation,
		marker.global_position,
		marker.global_transform.basis_xform(Vector2.RIGHT) * 2000.,
		GDSync.get_gdsync_owner(player),
	)


func set_body_collision_exceptions(bodies: Array[RigidBody2D]) -> void:
	for part in bodies:
		self.add_collision_exception_with(part)


func _physics_process(_delta: float) -> void:
	if GDSync.is_active() and not GDSync.is_host():
		return

	for body in colliding_bodies:
		if self.to_local(body.global_position).length() > bullet_occlusion_range:
			SignalBus.unregister_projectile_requested.emit(body)
