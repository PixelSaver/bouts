extends PixelMenu
class_name PasswordPopup

signal lobby_submitted(lobby_name: String, lobby_password: String)
signal lobby_canceled()
@export var bg: Control
@export var popup_cont: Control
@export var input_name: LineEdit
@export var input_password: LineEdit
@export var buttons: Array[DefaultButton]
var all_t: Array[Tweenable] = []
var t: Tween


func _ready() -> void:
	self.hide()
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))


func prompt_lobby_input(initial_lobby_name: String = "") -> void:
	input_name.text = initial_lobby_name
	input_password.clear()
	start_anim()


func _on_button_pressed(_name: String) -> void:
	match _name.to_lower():
		"submit":
			lobby_submitted.emit(input_name.text, input_password.text)
		"cancel":
			lobby_canceled.emit()
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])


func start_anim() -> void:
	if self.is_animating:
		return
	is_animating = true
	show()
	popup_cont.scale = Vector2.ZERO
	bg.modulate.a = 0.0
	if t and t.is_running():
		t.kill()
	t = default_tween()
	t.tween_property(popup_cont, "scale", Vector2.ONE, 0.7)
	t.tween_property(bg, "modulate:a", 1.0, 0.7)
	await t.finished
	is_animating = false


func end_anim() -> void:
	if self.is_animating:
		return
	is_animating = true
	if t and t.is_running():
		t.kill()
	t = default_tween()
	t.tween_property(popup_cont, "scale", Vector2.ZERO, 0.7)
	t.tween_property(bg, "modulate:a", 0.0, 0.7)
	await t.finished
	hide()
	is_animating = false
