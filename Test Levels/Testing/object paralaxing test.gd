extends Node2D

## 0 = stays fixed in the world (the focal plane, like the player's plane).
## Positive = appears farther away (moves slower on screen).
## Negative = appears closer (moves faster on screen, for foreground pieces).
@export var depth := 0.0
## Per-axis strength. Set y to 0 for horizontal-only parallax.
@export var axis_scale := Vector2.ONE
## Maximum shift in pixels, so far-away cameras don't fling layers off.
@export var max_offset := 200.0

var _base_pos: Vector2


func _ready() -> void:
	_base_pos = position


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var center := cam.get_screen_center_position()  # respects smoothing and limits
	var diff = (center - get_parent().global_position) * axis_scale
	var shift = (diff * depth).limit_length(max_offset)
	position = _base_pos + shift
