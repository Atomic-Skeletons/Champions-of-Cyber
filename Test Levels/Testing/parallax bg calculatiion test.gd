extends Parallax2D

## The point where the layers line up. Defaults to the parent object.
@export var anchor: Node2D

var child_start_pos: Vector2

func _ready() -> void:
	if anchor == null:
		anchor = get_parent() as Node2D
	_apply()
	child_start_pos = get_child(0).global_position
	print(child_start_pos)

func _apply() -> void:
	pass
	scroll_offset = -(Vector2.ONE - scroll_scale) * anchor.global_position/2
