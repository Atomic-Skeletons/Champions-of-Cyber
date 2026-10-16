extends Marker2D

@export var enemy_scene: PackedScene
var max_enemies = 10

func _on_timer_timeout() -> void:
	var total_enemies := get_tree().get_nodes_in_group("Enemy")
	if total_enemies.size() >= max_enemies:
		return
	
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	
	enemy.global_position = global_position
	get_parent().add_child(enemy)
