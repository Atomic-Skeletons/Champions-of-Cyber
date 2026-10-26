extends Line2D

@export var max_points: int = 15
var parent: Node2D

func _ready() -> void:
	parent = get_parent()
	#call_deferred("_reparent")
	clear_points()

func _process(_delta: float) -> void:
	if not is_instance_valid(parent):
		queue_free()
		return
	
	global_position = Vector2.ZERO
	# Add current global position to the front of the line
	add_point(parent.global_position)
	
	# Remove oldest points if the trail gets too long
	if get_point_count() > max_points:
		remove_point(0)

func _reparent():
	reparent(get_parent().get_parent())
