extends Weapon
class_name Mace

@export var colliding_bodies: Array[RigidBody2D]
@export var excluded_bodies: Array[RigidBody2D]
@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3


func _ready() -> void:
	self.set_meta("is_weapon", true)
	#for body in colliding_bodies:
	#body.body_entered.connect(_body_entered)


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	if _hit_cooldown <= 0.:
		var collided_bodies: Array[Node2D] = []
		for body in colliding_bodies:
			for col in body.get_colliding_bodies():
				collided_bodies.append(col)

		for col in collided_bodies:
			if Player.try_damage_player_body_part(_get_attack(), col, player if player else null):
				break

	if player and player.is_syncing_state == false:
		return


func set_body_collision_exceptions(bodies: Array[RigidBody2D]) -> void:
	for body in bodies:
		for weapon_body in excluded_bodies:
			weapon_body.add_collision_exception_with(body)
			body.add_collision_exception_with(weapon_body)

#
#func _body_entered(body: Node) -> void:
#if _hit_cooldown <= 0:
#Player.try_damage_player_body_part(_get_attack(), body, player if player else null)
#_hit_cooldown = hit_cooldown
