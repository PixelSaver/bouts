extends Projectile
class_name SniperBullet

@export var ricochet := true
@export var max_ricochets := 2
var ricochet_cooldown := .1
var _r_c := 0.0
var owner_player: Player

var ricochets := 0


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


func _process(delta: float) -> void:
	_r_c -= delta


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() == 0 or _r_c > 0.:
		return

	for i in state.get_contact_count():
		var collider := state.get_contact_collider_object(i)

		if Player.try_damage_player_body_part(
			_get_attack(),
			collider,
			owner_player,
		):
			SignalBus.unregister_projectile_requested.emit(self)
			return

		if ricochet and ricochets < max_ricochets:
			var normal := state.get_contact_local_normal(i)

			# Reflect the current velocity
			state.linear_velocity = state.linear_velocity.bounce(normal)

			ricochets += 1
			_r_c = ricochet_cooldown
		elif ricochet:
			SignalBus.unregister_projectile_requested.emit(self)
