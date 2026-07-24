extends PixelMenu
class_name AuthManager

@export_group("Nodes")
@export var login: AuthLogin
@export var register: AuthRegister
@export var verify: AuthVerify
@export var change_password: AuthChangePassword
@export var change_email: AuthChangeEmail
@export var change_identifier: AuthChangeIdentifier
@export var forgot_password: AuthForgotPassword
@export var reset_password: AuthResetPassword
@export var delete_account: AuthDeleteAccount
@export var states_cont: Control

@onready var states: Array[AuthMenu] = [
	login,
	register,
	verify,
	change_password,
	change_email,
	change_identifier,
	forgot_password,
	reset_password,
	delete_account,
]

var _current_state: AuthMenu


func _ready() -> void:
	_configure_signals()

	_transition_to_state(login)

	# identified signal emitted before the connection were made
	if Talo.current_alias:
		# _transition_to_state(in_game)
		pass


func _transition_to_state(state: AuthMenu):
	Log.pr("Transitioning to %s when current state is %s" % [state.name, _current_state])
	if _current_state != null:
		_current_state.end_anim()
	_current_state = state
	_current_state.start_anim()


func _configure_signals():
	login.verification_required.connect(
		func():
			Log.pr("Trying verify")
			_transition_to_state(verify),
	)
	login.go_to_forgot_password.connect(
		func():
			Log.pr("Trying forgot password")
			_transition_to_state(forgot_password),
	)
	login.go_to_register.connect(
		func():
			Log.pr("Trying register")
			_transition_to_state(register),
	)

	register.go_to_login.connect(
		func():
			Log.pr("Trying login")
			_transition_to_state(login),
	)

	# in_game.go_to_change_password.connect(func (): _transition_to_state(AuthState.CHANGE_PASSWORD))
	# in_game.go_to_change_email.connect(func (): _transition_to_state(AuthState.CHANGE_EMAIL))
	# in_game.go_to_change_identifier.connect(func (): _transition_to_state(AuthState.CHANGE_IDENTIFIER))
	# in_game.go_to_delete.connect(func (): _transition_to_state(AuthState.DELETE_ACCOUNT))
	# in_game.logout_success.connect(func (): _transition_to_state(AuthState.LOGIN))

	# change_password.password_change_success.connect(func (): _transition_to_state(AuthState.IN_GAME))
	# change_password.go_to_game.connect(func (): _transition_to_state(AuthState.IN_GAME))

	# change_email.email_change_success.connect(func (): _transition_to_state(AuthState.IN_GAME))
	# change_email.go_to_game.connect(func (): _transition_to_state(AuthState.IN_GAME))

	# change_identifier.identifier_change_success.connect(func (): _transition_to_state(AuthState.IN_GAME))
	# change_identifier.go_to_game.connect(func (): _transition_to_state(AuthState.IN_GAME))
	forgot_password.forgot_password_success.connect(
		func():
			Log.pr("Forgot password success")
			_transition_to_state(reset_password),
	)
	forgot_password.go_to_login.connect(
		func():
			Log.pr("Go to login")
			_transition_to_state(login),
	)

	reset_password.password_reset_success.connect(
		func():
			Log.pr("Password reset success")
			_transition_to_state(login),
	)
	reset_password.go_to_forgot_password.connect(
		func():
			Log.pr("Go to forgot password")
			_transition_to_state(forgot_password),
	)

	delete_account.delete_account_success.connect(
		func():
			Log.pr("Delete account success")
			_transition_to_state(login),
	)
	# delete_account.go_to_game.connect(func (): _transition_to_state(AuthState.IN_GAME))

	# Talo.players.identified.connect(func (player): _transition_to_state(AuthState.IN_GAME))
