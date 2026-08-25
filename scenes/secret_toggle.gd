extends CheckButton

@export var password: LineEdit

func _toggled(toggled_on: bool) -> void:
	password.secret = toggled_on
