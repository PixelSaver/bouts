extends Panel

@export var check_box:CheckBox

var _click_armed := true

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("l_click") and _click_armed:
		_click_armed = false
		check_box.button_pressed = !check_box.button_pressed
	if event.is_action_released("l_click"):
		_click_armed = true

func _ready() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
