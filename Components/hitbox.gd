class_name Hitbox
extends Area2D


@export var damage: int = 10
@export var damage_tags: Array[Data.damage_tag]

# knockback will be based on facing direction
@export_range(-180, 180) var knockback_angle: float
@export var knockback_strength: float

@export var screen_shake: PhantomCameraNoiseEmitter2D


func _ready() -> void:
	body_entered.connect(on_hit)

func on_hit(body: Node2D):
	var hit_health_component := get_health_component(body)
	if hit_health_component:
		screen_shake.emit()
		var knockback_rad = deg_to_rad(knockback_angle)
		var knockback_vector: Vector2 = Vector2.RIGHT.rotated(knockback_rad) * knockback_strength
		hit_health_component.damage(damage, damage_tags, knockback_vector)

func get_health_component(node: Node2D) -> HealthComponent:
	var health_component: HealthComponent = null
	
	if "health_component" in node:
		health_component = node.health_component
	
	return health_component
