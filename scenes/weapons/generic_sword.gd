extends Weapon
class_name GenericSword

@export var hit_cooldown := 0.3
var _hit_cooldown := 0.3

func _ready() -> void:
	self.set_meta("is_weapon", true)
	self.body_entered.connect(_body_entered)

func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta

func _body_entered(body:Node) -> void:
	var par = body.get_parent()
	if par is not Player: return
	push_warning("Body entered: %s" % body.name)
	if _hit_cooldown <= 0: 
		hit_player(par as Player)

func hit_player(player:Player):
	player.damage(_get_attack())
	_hit_cooldown = hit_cooldown
