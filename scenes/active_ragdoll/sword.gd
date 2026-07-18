extends RigidBody2D

@export var damage := 1.

func _ready() -> void:
	self.set_meta("is_weapon", true)

func _body_entered(body:Node) -> void:
	var par = body.get_parent()
	if par is not Player: return
	push_warning("Body entered: %s" % body.name)
	var player = par as Player
	var atk = Attack.new()
	atk.damage = damage
	player.damage(atk)
