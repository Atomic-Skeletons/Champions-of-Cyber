extends RigidBody2D


@export var damage: int = 10
@export var damage_tags: Array[Data.damage_tag]
@export var knockback_dir := Vector2(1 , 1)
@export var knockback_strength: float = 20
@export var hit_screen_shake: PhantomCameraNoiseEmitter2D

func _on_body_entered(body: Node) -> void:
	var health_component := Global.get_health_component(body)
	if health_component:
		health_component.damage(damage, damage_tags, knockback_dir * knockback_strength)
	hit_screen_shake.emit()
	queue_free()
