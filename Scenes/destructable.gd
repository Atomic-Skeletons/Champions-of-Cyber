extends StaticBody2D

@onready var health_component: HealthComponent = %HealthComponent


func _on_health_component_died() -> void:
	queue_free()
