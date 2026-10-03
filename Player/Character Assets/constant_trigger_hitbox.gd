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
			var final_attack_data := attack_data
			if knockback_flipped:
				final_attack_data = attack_data.get_reversed_knockback_andle()
			
			hit_health_component.damage(final_attack_data)
