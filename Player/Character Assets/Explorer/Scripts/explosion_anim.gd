extends AnimatedSprite2D

@export var hit_shake: PhantomCameraNoiseEmitter2D

func _ready() -> void:
	hit_shake.emit()

func _on_animation_finished() -> void:
	queue_free()
