class_name Hitbox
extends Area2D

signal hit_body(body: Node2D)

@export var damage: int = 10
@export var damage_tags: Array[Data.damage_tag]

# knockback will be based on facing direction
@export_range(-180, 180) var knockback_angle: float
var knockback_flipped := false
@export var knockback_strength: float

@export var hitstun_duration: float = .5
#@export var invincibility_duration: float = 1

@export var screen_shake: PhantomCameraNoiseEmitter2D


func _ready() -> void:
	body_entered.connect(on_hit)

func on_hit(body: Node2D):
	var hit_health_component := Global.get_health_component(body)
	if hit_health_component:
		hit_body.emit(body)
		if screen_shake:
			screen_shake.emit()
		var angle = knockback_angle
		if knockback_flipped:
			angle = 180 - knockback_angle
		var knockback_rad = deg_to_rad(angle)
		var knockback_vector: Vector2 = Vector2.RIGHT.rotated(knockback_rad) * knockback_strength
		hit_health_component.damage(damage, damage_tags, knockback_vector, hitstun_duration)
