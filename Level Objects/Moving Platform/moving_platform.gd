extends AnimatableBody2D

@export var path : PathFollow2D
var progress := 0.0
@export var move_speed : float = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path.progress += move_speed * delta
