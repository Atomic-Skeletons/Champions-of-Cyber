class_name ConstantHitbox extends Hitbox


@export var damage_interval: float

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = damage_interval
	timer.start()
	timer.timeout.connect(on_tick)

func on_tick():
	var bodies := get_overlapping_bodies()
	for body in bodies:
		var hit_health_component := Global.get_health_component(body)
	
		if hit_health_component:
			#screen_shake.emit()
			var angle = knockback_angle
			if knockback_flipped:
				angle = 180 - knockback_angle
			var knockback_rad = deg_to_rad(angle)
			var knockback_vector: Vector2 = Vector2.RIGHT.rotated(knockback_rad) * knockback_strength
			hit_health_component.damage(damage, damage_tags, knockback_vector, hitstun_duration)
