extends Node2D

@onready var camera_pivot_point: Node3D = $"CanvasLayer/CenterContainer/SubViewportContainer/SubViewport/Camera Pivot Point"

@export var current_level_marker: LevelMarker:
	set(value):
		current_level_marker = value
		move_to_marker()

var camera_moving_tween: Tween
@onready var level_marker_controller: Marker3D = %"Level Marker Controller"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_pivot_point.look_at(level_marker_controller.global_position)
	
	#var x_dir = Input.get_axis("left", "right")
	#var y_dir = Input.get_axis("up", "down")
	#var dir = Vector3(x_dir, y_dir, 0)/5
	#camera_pivot_point.global_position += dir
	
	if Input.is_action_just_pressed("ui_up"):
		if current_level_marker.up_marker:
			current_level_marker = current_level_marker.up_marker
	elif Input.is_action_just_pressed("ui_down"):
		if current_level_marker.down_marker:
			current_level_marker = current_level_marker.down_marker
	elif Input.is_action_just_pressed("ui_left"):
		if current_level_marker.left_marker:
			current_level_marker = current_level_marker.left_marker
	elif Input.is_action_just_pressed("ui_right"):
		if current_level_marker.right_marker:
			current_level_marker = current_level_marker.right_marker

func move_to_marker():
	pass
	camera_moving_tween = Utilities.reset_tween(camera_moving_tween, self)
	camera_moving_tween.tween_property(
		level_marker_controller, "global_position", 
		current_level_marker.global_position, 
		1)
