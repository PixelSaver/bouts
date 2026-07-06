extends RigidBody2D
class_name Player

@export var acceleration := 400
@export var jump_strength := 400
var is_on_floor := false
var _jump_buffer := 0.3
var _jump_buffer_max := 0.3
var input_dir : float
var input_jump : bool

func _physics_process(delta: float) -> void:
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
	var dir := Input.get_axis("left", "right")
	var jump = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")
	if multiplayer.is_server():
		input_dir = dir
		input_jump = jump
	else:
		submit_input.rpc(dir, jump)

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

func _process_movement(dir:float, jump:bool, delta:float) -> void:
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

	
