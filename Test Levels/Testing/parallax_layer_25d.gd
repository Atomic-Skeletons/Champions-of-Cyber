class_name ParallaxLayer25D
extends Node2D

## 1 = fixed in the world, <1 = farther away, >1 = closer. Per axis.
@export var scroll_scale := Vector2.ONE
## Camera position at which this layer looks exactly as laid out in the editor.
## Leave empty for objects: the layer's own position is used.
@export var anchor: Node2D
## Tile size for repeating layers. Leave an axis at 0 to not repeat on it.
@export var repeat_size := Vector2.ZERO
@export var repeat_times := 2
## Round to whole pixels (helps pixel art avoid shimmering).
@export var snap_to_pixels := false

var _base: Vector2
var _anchor_pos: Vector2


func _ready() -> void:
	# Run after the camera has moved this frame so layers never lag a frame behind
	process_priority = 100
	_base = global_position
	_anchor_pos = anchor.global_position if anchor else _base
	# Take over positioning in world space so a moving parent can't interfere
	#top_level = true
	global_position = _base
	
	# repeating for the x axis
	if repeat_size.x > 0:
		for i in repeat_times:
			for child in get_children():
				var duped_child = child.duplicate()
				add_child(duped_child)
				# if this is an odd then add to the right
				var times = i + 1
				if times % 2 == 1:
					duped_child.global_position.x += repeat_size.x * ceili(times/2.)
				else:
					duped_child.global_position.x -= repeat_size.x * ceili(times/2.)
	# repeating for the y axis
	if repeat_size.y > 0:
		for i in repeat_times:
			for child in get_children():
				var duped_child = child.duplicate()
				add_child(duped_child)
				# if this is an odd then add to the right
				var times = i + 1
				if times % 2 == 1:
					duped_child.global_position.y += repeat_size.y * ceili(times/2.)
				else:
					duped_child.global_position.y -= repeat_size.y * ceili(times/2.)


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var c := cam.get_screen_center_position()   # what the player actually sees

	var pos := _base + (Vector2.ONE - scroll_scale) * (c - _anchor_pos)

	# Repeating: slide by whole tiles so the pattern stays centered on the camera
	if repeat_size.x > 0.0:
		pos.x += roundf((c.x - pos.x) / repeat_size.x) * repeat_size.x
	if repeat_size.y > 0.0:
		pos.y += roundf((c.y - pos.y) / repeat_size.y) * repeat_size.y

	if snap_to_pixels:
		pos = pos.round()
	global_position = pos
