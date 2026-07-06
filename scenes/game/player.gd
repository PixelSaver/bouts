extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var input_dir : float
var input_jump : bool

func _physics_process(delta: float) -> void:
	_handle_movement()
	if not multiplayer.is_server(): return
	_process_movement(input_dir, input_jump, delta)

func _handle_movement():
	if not is_multiplayer_authority(): return # only client controls client player
	var dir := Input.get_axis("ui_left", "ui_right")
	var jump = Input.is_action_just_pressed("space")
	if multiplayer.is_server():
		input_dir = dir
		input_jump = jump
	else:
		submit_input.rpc(dir, jump)
	# Add the gravity.
	#if is_multiplayer_authority():
		#_update_position.rpc(self.position, self.velocity)

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
	velocity = vel

func _process_movement(dir:float, jump:bool, delta:float) -> void:
	var can_jump := true
	if not is_on_floor():
		can_jump = false
		velocity += get_gravity() * delta

	if jump and can_jump:
		velocity.y = JUMP_VELOCITY
	var direction := dir
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	sync_state.rpc(global_position, velocity)

	
