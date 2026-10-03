class_name Hitbox
extends Area2D

signal hit_body(body: Node2D)

@export var attack_data: AttackData

var knockback_flipped := false

@export var screen_shake: PhantomCameraNoiseEmitter2D


func _ready() -> void:
	body_entered.connect(on_hit)

func on_hit(body: Node2D):
	var hit_health_component := Global.get_health_component(body)
	if hit_health_component:
		hit_body.emit(body)
		if screen_shake:
			screen_shake.emit()
		
		var final_attack_data := attack_data
		if knockback_flipped:
			final_attack_data = attack_data.get_reversed_knockback_andle()
		
		hit_health_component.damage(final_attack_data)
