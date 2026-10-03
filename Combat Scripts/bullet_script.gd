extends RigidBody2D


@export var attack_data: AttackData = AttackData.new()

@export var explosion_anim: PackedScene

var last_moving_dir: int

func _process(_delta: float) -> void:
	last_moving_dir = sign(linear_velocity.x)

func _on_body_entered(body: Node) -> void:
	var health_component := Global.get_health_component(body)
	if health_component:
		var final_attack_data := attack_data
		
		if last_moving_dir < 0:
			final_attack_data = attack_data.get_reversed_knockback_andle()
		
		health_component.damage(final_attack_data)
	
	var explosion: AnimatedSprite2D = explosion_anim.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	queue_free()
