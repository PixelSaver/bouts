extends RigidBody2D
class_name Player

signal died
@export_subgroup("Nodes", "_")
@export var _health_component: HealthComponent
@export var _sprite: Sprite2D
@export var _col: CollisionShape2D
@export var _gun: Node2D
@export var acceleration := 400
@export var jump_strength := 400
@export var _damage := 1.
@export var sensitivity := 1.
@export var gun_radius := 35
var is_on_floor := false
var _jump_buffer := 0.3
var _jump_buffer_max := 0.3
var _shoot_buffer := 0.2
var _shoot_buffer_max := 0.2
var _gun_angle := 0.
var _player_scale := 1.0
var input_dir : float
var input_jump : bool

func _ready() -> void:
	_health_component.death.connect(_on_death)

#region Input
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		var diff = event.relative * sensitivity
		_gun.position = (_gun.position + diff).normalized() * gun_radius
		_gun_angle = _gun.position.angle()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _handle_input():
	if not is_multiplayer_authority(): 
		_gun.position = Vector2.RIGHT.rotated(_gun_angle) * gun_radius
		return # only client controls client player
	
	
	var dir := Input.get_axis("left", "right")
	var jump = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")
	var _shoot = Vector2.ZERO
	if Input.is_action_just_pressed("l_click"):
		submit_shot.rpc(_gun_angle, multiplayer.get_unique_id())
	if multiplayer.is_server():
		input_dir = dir
		input_jump = jump
	else:
		submit_input.rpc(dir, jump, _gun_angle)

@rpc("any_peer", "reliable")
func submit_shot(angle:float, id:int):
	if not _shoot_buffer < 0.: return
	_shoot_buffer = _shoot_buffer_max
	sync_bullet.rpc(angle, id)
@rpc("any_peer", "reliable", "call_local")
func sync_bullet(angle:float, id:int):
	if !multiplayer.is_server(): return
	SignalBus.bullet_spawned.emit(Attack.spawn_attack(_damage), angle, self.global_position, id)
	#add_child(bullet)
@rpc("any_peer", "unreliable")
## Sending input from client to server
func submit_input(dir:float, jump:bool, gun_angle:float) -> void:
	input_dir = dir
	input_jump = jump
	_gun_angle = gun_angle

@rpc("any_peer", "unreliable")
## Server processing and then sending back
func sync_state(pos:Vector2, vel:Vector2, gun_angle:float) -> void:
	if multiplayer.is_server(): return # don't overwrite server's local player
	global_position = pos
	linear_velocity = vel
	_gun_angle = gun_angle
#endregion

#region Movement
func _process_movement(dir:float, jump:bool, _delta:float) -> void:
	var can_jump := true
	if not is_on_floor:
		can_jump = false

	if can_jump and (jump or _jump_buffer > 0.):
		self.apply_central_impulse(Vector2.UP * jump_strength)
		self._jump_buffer = self._jump_buffer_max
	var direction := dir
	#velocity.x = direction * acc if direction else move_toward(velocity.x, 0, acceleration)
	if direction:
		self.apply_central_force(Vector2.RIGHT * direction * acceleration)
	if multiplayer.is_server():
		sync_state.rpc(global_position, linear_velocity, _gun_angle)

func _physics_process(delta: float) -> void:
	_shoot_buffer -= delta
	_jump_buffer -= delta
	_handle_input()
	if not multiplayer.is_server(): return
	_process_movement(input_dir, input_jump, delta)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_on_floor = false
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		#var point = state.get_contact_local_position(i)
		if normal.dot(Vector2.UP) > 0.999:
			is_on_floor = true
#endregion

func apply_upgrades(ups:Array[UpgradeManager.Upgrades]):
	for up in ups:
		UpgradeManager.apply_upgrade(self, up)

#region Upgrade functions
func get_player_scale() -> float: return _player_scale
func set_player_scale(player_scale: float):
	_player_scale = player_scale
	_sprite.scale = Vector2.ONE * player_scale * 0.5
	gun_radius = int(35. * player_scale)
	(_col.shape as CircleShape2D).radius = 30 * player_scale
#endregion

func _on_death() -> void:
	died.emit()
	#queue_free()
func damage(atk:Attack):
	_health_component.damage(atk)
