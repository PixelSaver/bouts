extends Button

var counter := 0
func _ready() -> void:
	self.pressed.connect(func():
		_update_num.rpc()
	)

@rpc("authority", "call_local")
func _update_num() -> void:
	counter += 1
	self.text = str(counter)
