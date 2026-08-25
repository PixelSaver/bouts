extends Weapon
class_name GenericSword

@export var colliding_bodies: Array[RigidBody2D]
@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3


func _ready() -> void:
	self.set_meta("is_weapon", true)


func apply_skill(_player: Player = player) -> void:
	Log.pr("Sword skill done")
	_player.torso.apply_central_impulse(Vector2.DOWN.rotated(_player.weapon.global_rotation) * 3000.)


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
