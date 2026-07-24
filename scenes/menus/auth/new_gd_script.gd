extends CheckButton

@onready var password: LineEdit = %Password

func _toggled(toggled_on: bool) -> void:
	password.secret = toggled_on
