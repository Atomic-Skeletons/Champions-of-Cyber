extends CanvasLayer
#
#@onready var camera_pivot_point: Node3D = $"CanvasLayer/CenterContainer/SubViewportContainer/SubViewport/Camera Pivot Point"
#
#@export var current_level_marker: LevelMarker:
	#set(value):
		#current_level_marker = value
		#move_to_marker()
#
#var camera_moving_tween: Tween
#@onready var level_marker_controller: Marker3D = %"Level Marker Controller"
@export var current_level_marker: LevelMarker
@export var camera: Camera3D
@export var globe: Node3D                 # the node that rotates; markers are its children
@export var duration := 1.

signal focus_finished(marker: Node3D)

var current_marker: Node3D
var _tween: Tween


func _ready() -> void:
	focus_on_instant(current_level_marker)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#var x_dir = Input.get_axis("left", "right")
	#var y_dir = Input.get_axis("up", "down")
	#var dir = Vector3(x_dir, y_dir, 0)/5
	#camera_pivot_point.global_position += dir
	var new_marker := current_level_marker
	if Input.is_action_just_pressed("ui_up"):
		if current_level_marker.up_marker:
			new_marker = current_level_marker.up_marker
	elif Input.is_action_just_pressed("ui_down"):
		if current_level_marker.down_marker:
			new_marker = current_level_marker.down_marker
	elif Input.is_action_just_pressed("ui_left"):
		if current_level_marker.left_marker:
			new_marker = current_level_marker.left_marker
	elif Input.is_action_just_pressed("ui_right"):
		if current_level_marker.right_marker:
			new_marker = current_level_marker.right_marker
	
	if new_marker != current_level_marker:
		focus_on(new_marker)
		current_level_marker = new_marker

# Smoothly rotate the globe so `marker` ends up in the center of the camera view.
func focus_on(marker: LevelMarker) -> void:
	current_marker = marker
	var target := _target_quat_for(marker)
	var start := Quaternion(globe.basis)

	_tween = Utilities.reset_tween(_tween, self)
	_tween.tween_method(
		func(t: float) -> void:
			globe.basis = Basis(start.slerp(target, t)),
		0.0, 1.0, duration
	)
	_tween.finished.connect(func() -> void: focus_finished.emit(marker))


# Snap with no animation (useful when the menu first loads).
func focus_on_instant(marker: LevelMarker) -> void:
	current_marker = marker
	if _tween and _tween.is_valid():
		_tween.kill()
	globe.basis = Basis(_target_quat_for(marker))


func _target_quat_for(marker: LevelMarker) -> Quaternion:
	# Marker direction in the globe's own local space (independent of its current rotation)
	var d: Vector3 = globe.to_local(marker.global_position).normalized()
	# Direction from the globe's center toward the camera, in world space
	var c: Vector3 = (camera.global_position - globe.global_position).normalized()

	var local_look := _look_basis(d)    # maps -Z -> marker direction (globe space)
	var world_look := _look_basis(c)    # maps -Z -> camera direction (world space)

	# B such that B * d = c, with a stable up axis so the poles stay upright
	return Quaternion(world_look * local_look.inverse())


func _look_basis(dir: Vector3) -> Basis:
	# Fall back to another up vector if dir is (nearly) parallel to UP
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.999 else Vector3.FORWARD
	return Basis.looking_at(dir, up)

#func move_to_marker():
	#camera_moving_tween = Utilities.reset_tween(camera_moving_tween, self)
	#camera_moving_tween.tween_property(
		#level_marker_controller, "global_position", 
		#current_level_marker.global_position, 
		#1)
