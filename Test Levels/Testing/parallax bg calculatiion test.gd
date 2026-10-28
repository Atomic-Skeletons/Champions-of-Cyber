extends Parallax2D

## Camera position at which the layers line up. Defaults to the parent object.
@export var anchor: Node2D
## If true, every sprite aligns when the camera is on that sprite itself.
@export var anchor_each_child := false


func _ready() -> void:
	var a := (anchor if anchor else get_parent() as Node2D).global_position
	var k := Vector2.ONE - scroll_scale   # per-axis, so non-uniform scales work too

	for child in get_children():
		if child is Node2D:
			var g: Vector2 = child.global_position          # where you placed it in the editor
			var pivot := g if anchor_each_child else a
			child.global_position = g - k * pivot
