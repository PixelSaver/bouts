extends Weapon
class_name Gun

@export var colliding_bodies: Array[Projectile]
@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3


func _ready() -> void:
	self.set_meta("is_weapon", true)
	SignalBus.projectile_spawned.connect(_on_proj_spawned)


func _on_proj_spawned(p: Projectile, owner_id: int):
	if not player:
		return
	if GDSync.get_gdsync_owner(player) != owner_id:
		return
	colliding_bodies.append(p)
	p.tree_exiting.connect(_erase_p.bind(p))


func _erase_p(p: Projectile) -> void:
	colliding_bodies.erase(p)


func apply_skill(_player: Player = player) -> void:
	Log.pr("Gun shooting")
	var atk = Attack.new()
	atk.damage = 1.0
	SignalBus.projectile_spawn_requested.emit(
		ProjectileManager.ProjectileType.DEFAULT,
		atk,
		self.global_rotation,
		self.global_position,
		GDSync.get_gdsync_owner(player),
	)


func set_body_collision_exceptions(bodies: Array[RigidBody2D]) -> void:
	for part in bodies:
		self.add_collision_exception_with(part)


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	if _hit_cooldown <= 0.:
		var collided_bodies: Array[Node2D] = []
		for body in colliding_bodies:
			for col in body.get_colliding_bodies():
				collided_bodies.append(col)

		for col in collided_bodies:
			if Player.try_damage_player_body_part(_get_attack(), col, player if player else null):
				_hit_cooldown = hit_cooldown
				break

	if player and player.is_syncing_state == false:
		return
