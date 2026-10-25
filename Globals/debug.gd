extends Node


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_MINUS:
			Engine.time_scale -= .1
			Engine.time_scale = max(Engine.time_scale, .1)
		if event.keycode == KEY_EQUAL:
			Engine.time_scale += .1
