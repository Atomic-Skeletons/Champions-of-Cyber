extends RigidBody2D


@export var damage: int = 10
@export var damage_tags: Array[Data.damage_tag]
@export var knockback_dir := Vector2(1 , 1)
@export var knockback_strength: float = 20
@export var hit_screen_shake: PhantomCameraNoiseEmitter2D
@export var explosion_anim: PackedScene
@export var hitstun_duration: float
@export var new_time_scale: float

func _on_body_entered(body: Node) -> void:
	var health_component := Global.get_health_component(body)
	if health_component:
		health_component.damage(damage, damage_tags, knockback_dir * knockback_strength, hitstun_duration)
		TimeController.control_time_scale(new_time_scale, hitstun_duration, 0, 0, 1)
	#hit_screen_shake.emit()
	
	var explosion: AnimatedSprite2D = explosion_anim.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	queue_free()
