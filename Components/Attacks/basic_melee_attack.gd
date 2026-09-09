@tool
class_name BasicMeleeAttack extends AttackComponent

var damage = 10
var can_attack = true

@export var hitbox : Area2D:
	set(value):
		hitbox = value
		update_configuration_warnings()
@onready var collision_shape_2d: CollisionShape2D = $"../Hitbox/CollisionShape2D"
@export var  cooldown_timer: Timer
@export var attack_duration_timer: Timer

func _ready() -> void:
	collision_shape_2d.disabled = true
	cooldown_timer.timeout.connect(reset_attack)
	attack_duration_timer.timeout.connect(attack_over)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	update_configuration_warnings()

func attack(body: CharacterBody2D, direction: Vector2):
	if can_attack:
		if direction.x != 0:
			if direction.x > 0:
				hitbox.position.x = abs(hitbox.position.x)
			else:
				hitbox.position.x = -abs(hitbox.position.x)
		
		collision_shape_2d.disabled = false
		can_attack = false
		attack_duration_timer.start()

func reset_attack():
	can_attack = true

func attack_over():
	collision_shape_2d.disabled = true
	cooldown_timer.start()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if not hitbox:
		warnings.append("Hitbox is not set")
	
	return warnings


func _on_hitbox_body_entered(body: Node2D) -> void:
	# We hit something
	if "health_component" in body:
		var health_component : HealthComponent = body.health_component
		health_component.damage(damage)
