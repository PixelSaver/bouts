extends Weapon
class_name GenericSword

@export var hit_cooldown := 0.3
@export var player: Player
var _hit_cooldown := 0.3


func _ready() -> void:
	self.set_meta("is_weapon", true)
	self.body_entered.connect(_body_entered)


func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	if player.is_syncing_state == false:
		return
	if multiplayer.is_server():
		_sync_state.rpc(global_position, global_rotation, linear_velocity, angular_velocity)


@rpc("any_peer", "unreliable", "call_remote")
func _sync_state(pos: Vector2, rot: float, vel: Vector2, ang_vel: float) -> void:
	self.global_position = pos
	self.global_rotation = rot
	self.linear_velocity = vel
	self.angular_velocity = ang_vel


func _body_entered(body: Node) -> void:
	var par = body.get_parent()
	if par is not Player:
		return
	if _hit_cooldown <= 0:
		hit_player(par as Player)


func hit_player(player: Player):
	player.damage(_get_attack())
	_hit_cooldown = hit_cooldown
