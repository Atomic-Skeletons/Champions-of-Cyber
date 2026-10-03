extends StaticBody2D


@onready var health_component: HealthComponent = $HealthComponent

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	look_at(Global.get_closest_character(self).global_position)

func shoot():
	var bullet_object: RigidBody2D = bullet_scene.instantiate()
	bullet_object.global_position = global_position
	get_parent().add_child(bullet_object)
	
	var closest_character = Global.get_closest_character(self)
	
	bullet_object.look_at(closest_character.global_position)
	
	var direction = (closest_character.global_position - global_position).normalized()
	bullet_object.linear_velocity = direction * bullet_speed

func _on_shot_interval_timer_timeout() -> void:
	shoot()
