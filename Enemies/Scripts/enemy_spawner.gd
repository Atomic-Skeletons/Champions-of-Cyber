extends Marker2D

@export var enemy_scene: PackedScene


func _on_timer_timeout() -> void:
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	
	get_parent().add_child(enemy)
	enemy.global_position = global_position
