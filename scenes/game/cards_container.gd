@tool
extends Container
class_name CardsContainer

@export var spread: float = 1.0 :
	set(val):
		spread = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var radius: float = 100.0 :
	set(val):
		radius = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var center: Vector2 = Vector2(0, -100) :
	set(val):
		center = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()

#region Child connection
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exited_tree)
	for child in get_children():
		_connect_child(child)
func _on_child_entered_tree(child:Node) -> void:
	var _child = child as Control
	_connect_child(_child)
func _on_child_exited_tree(child:Node) -> void:
	var _child = child as Control
	_disconnect_child(_child)
func _connect_child(child:Control):
	child.offset_transform_enabled = true
	child.pivot_offset_ratio = Vector2.ONE * 0.5
	child.mouse_entered.connect(_on_child_mouse_entered.bind(child))
	child.mouse_exited.connect(_on_child_mouse_exited.bind(child))
func _disconnect_child(child:Control):
	child.mouse_entered.disconnect(_on_child_mouse_entered)
	child.mouse_exited.disconnect(_on_child_mouse_exited)
func _on_child_mouse_entered(child: Control):
	var t = get_tree().create_tween().bind_node(child)
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(child, "offset_transform_position", Vector2.UP.rotated(child.offset_transform_rotation) * 100., 0.7)
func _on_child_mouse_exited(child: Control):
	var t = get_tree().create_tween().bind_node(child)
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(child, "offset_transform_position", Vector2.ZERO, 0.7)
#endregion

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_update_children()

func _update_children():
	var children = get_children()
	var theta = spread * 2.0 / (children.size()-1) if children.size() > 1 else 0.0
	var _center = self.get_rect().size * Vector2(0.5, 1.0) + center

	for i in range(children.size()):
		var child = children[i] as Control
		var current_angle = -spread + (theta * i) 
		#if flip:
			#current_angle = PI - current_angle
		var pos = _center + Vector2.UP.rotated(current_angle) * radius
		child.pivot_offset_ratio = Vector2.ONE * 0.5
		#child.rotation = current_angle
		child.offset_transform_rotation = current_angle
		var child_size = child.get_combined_minimum_size()
		fit_child_in_rect(child, Rect2(pos - (child_size / 2.0), child_size))
