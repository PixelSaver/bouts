extends RigidBody2D

@export var damage := 1.
@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3

func _ready() -> void:
	self.set_meta("is_weapon", true)

func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta

func _body_entered(body:Node) -> void:
	var par = body.get_parent()
	if par is not Player: return
	push_warning("Body entered: %s" % body.name)
	if _hit_cooldown <= 0: 
		hit_player(par as Player)

func hit_player(player:Player):
	var atk = Attack.new()
	atk.damage = damage
	player.damage(atk)
	_hit_cooldown = hit_cooldown
