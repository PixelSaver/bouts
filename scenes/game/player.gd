extends RigidBody2D
class_name Player

signal died
@export_subgroup("Nodes", "_")
@export var _health_component: HealthComponent
@export var acceleration := 400
@export var jump_strength := 400
@export var _damage := 1.
@export var sensitivity := 1.
var is_on_floor := false
var _jump_buffer := 0.3
var _jump_buffer_max := 0.3
var _shoot_buffer := 0.2
var _shoot_buffer_max := 0.2
var input_dir : float
var input_jump : bool

func _ready() -> void:
	_health_component.death.connect(_on_death)

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

func _handle_input():
	if not is_multiplayer_authority(): return # only client controls client player
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	var dir := Input.get_axis("left", "right")
	var jump = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")
	var _shoot = Vector2.ZERO
	if Input.is_action_just_pressed("l_click"):
		_shoot = (get_global_mouse_position() - self.global_position).normalized()
		submit_shot.rpc(_shoot.angle(), multiplayer.get_unique_id())
	if multiplayer.is_server():
		input_dir = dir
		input_jump = jump
	else:
		submit_input.rpc(dir, jump)

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
func submit_input(dir:float, jump:bool) -> void:
	input_dir = dir
	input_jump = jump

@rpc("any_peer", "unreliable")
## Server processing and then sending back
func sync_state(pos:Vector2, vel:Vector2) -> void:
	if multiplayer.is_server(): return # don't overwrite server's local player
	global_position = pos
	linear_velocity = vel

#func _process_shoot(shoot)
	#if _shoot != Vector2.ZERO and _shoot_buffer < 0.:
		#if multiplayer.is_server(): self.shoot.rpc(input_shoot.angle())

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
		sync_state.rpc(global_position, linear_velocity)

	
func _on_death() -> void:
	died.emit()
	#queue_free()
func damage(atk:Attack):
	_health_component.damage(atk)
