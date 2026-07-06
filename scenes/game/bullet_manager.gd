extends Node2D

var bullets: Array[Bullet] = []

func _ready() -> void:
	SignalBus.bullet_spawned.connect(register_bullet)

func register_bullet(bullet:Bullet) -> void:
	self.add_child(bullet)
	bullets.append(bullet)
	bullet.tree_exiting.connect(func(): bullets.erase(bullet))
