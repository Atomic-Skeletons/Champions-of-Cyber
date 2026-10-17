extends StaticBody2D


@onready var health_component: HealthComponent = $HealthComponent

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 50
@onready var player_detection_cast: PlayerDetectionCast = $PlayerDetectionCast

var attacking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not attacking: return
	look_at(Global.get_closest_character(self).global_position)

func shoot():
	if not attacking: return
	
	var bullet_object: RigidBody2D = bullet_scene.instantiate()
	get_parent().add_child(bullet_object)
	bullet_object.global_position = global_position
	
	var closest_character = Global.get_closest_character(self)
	
	bullet_object.look_at(closest_character.global_position)
	
	var direction = (closest_character.global_position - global_position).normalized()
	bullet_object.linear_velocity = direction * bullet_speed

func _on_shot_interval_timer_timeout() -> void:
	shoot()


func _on_health_component_died() -> void:
	queue_free()


func _on_player_detection_cast_saw_character(character: Character) -> void:
	attacking = true
