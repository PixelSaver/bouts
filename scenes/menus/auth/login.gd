extends AuthMenu
class_name AuthLogin

signal verification_required
signal go_to_forgot_password
signal go_to_register

@onready var username: LineEdit = %Username
@onready var password: LineEdit = %Password
@onready var validation_label: Label = %ValidationLabel
#@onready var submit: DefaultButton = $MarginContainer/VBoxContainer/Submit
#@onready var forgot_password: DefaultButton = $MarginContainer/VBoxContainer/ForgotPassword
#@onready var register: DefaultButton = $MarginContainer/VBoxContainer/Register

#func _ready() -> void:
#submit.pressed.connect(_on_submit_pressed)
#forgot_password.pressed.connect(_on_forgot_password_pressed)
#register.pressed.connect(_on_register_pressed)


func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not username.text:
		validation_label.text = "Username is required"
		return

	if not password.text:
		validation_label.text = "Password is required"
		return

	var res := await Talo.player_auth.login(username.text, password.text)
	match res:
		Talo.player_auth.LoginResult.FAILED:
			Log.pr("Login failed!")
			match Talo.player_auth.last_error.get_code():
				TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
					validation_label.text = "Username or password is incorrect"
				_:
					validation_label.text = Talo.player_auth.last_error.get_string()
		Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
			verification_required.emit()
			Log.pr("Verification required!")
		Talo.player_auth.LoginResult.OK:
			Log.pr("Login result went through!")


func _on_forgot_password_pressed() -> void:
	go_to_forgot_password.emit()


func _on_register_pressed() -> void:
	go_to_register.emit()
