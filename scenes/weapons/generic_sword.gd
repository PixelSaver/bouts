extends Weapon
class_name GenericSword

@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3


func _ready() -> void:
	self.set_meta("is_weapon", true)
	self.body_entered.connect(_body_entered)


func apply_skill(_player: Player = player) -> void:
	Log.pr("Sword skill done")
	_player.torso.apply_central_impulse(Vector2.DOWN.rotated(_player.weapon.global_rotation) * 3000.)


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta


func set_body_collision_exceptions(bodies: Array[RigidBody2D]) -> void:
	for part in bodies:
		self.add_collision_exception_with(part)


func _body_entered(body: Node) -> void:
	if _hit_cooldown <= 0:
		Player.try_damage_player_body_part(_get_attack(), body, player)
		_hit_cooldown = hit_cooldown
