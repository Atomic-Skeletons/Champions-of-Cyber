class_name HealthComponent extends Node

signal died()
signal knockback(vector: Vector2)
signal damaged(amount, hitstun_duration, hitstop_duration)
signal hit(amount, knockback_vector, knockback_duration, hitstun_duration)
signal healed(amount)

@export_category("Health")
@export var max_hp = 10
var current_hp = 10
@export var invincibility_duration := 1.
@onready var invincibility_timer := Timer.new()

@export_category("Tags")
@export var immunity_tags: Array[AttackData.damage_tag]
@export var weakness_tags: Array[AttackData.damage_tag]
## If this is set to true, only damage tags that match a weakness will deal damage.
## Useful for destructables that can only be damaged by a specific tag
@export var weakness_only_damage: bool

func _ready() -> void:
	current_hp = max_hp
	invincibility_timer.one_shot = true
	invincibility_timer.wait_time = invincibility_duration
	invincibility_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(invincibility_timer)

func damage(data: AttackData):
	#amount: int, damage_tags: Array[Data.damage_tag], knockback_vector: Vector2, hitstun_duration: float
	if can_damage(data.damage_tags):
		current_hp -= data.damage
		
		
		var knockback_rad = deg_to_rad(data.knockback_angle)
		var knockback_vector: Vector2 = Vector2.RIGHT.rotated(-knockback_rad) * data.knockback_strength
		
		
		hit.emit(
			data.damage,
			knockback_vector * 10,
			data.knockback_duration,
			data.hitstun_duration)
		
		invincibility_timer.start()
	
	if current_hp <= 0:
		died.emit()

func heal(amount):
	if current_hp <= max_hp:
		healed.emit(max_hp - current_hp)
	current_hp += amount
	current_hp = min(max_hp, current_hp)

func can_damage(damage_tags: Array[AttackData.damage_tag]) -> bool:
	if is_invincible(): return false
	if not immunity_tags:
		return true
	# if any of the damage tags are in the immunity tag, 
	if weakness_only_damage:
		# can only damage if tag is in weaknesses
		for tag in damage_tags:
			if tag in weakness_tags:
				return true
		return false
	else:
		# can only damage if there is at least 1 tag not in immunities
		for tag in damage_tags:
			if tag not in immunity_tags:
				return true
		return false

func is_invincible() -> bool:
	if invincibility_timer.is_stopped():
		return false
	return true
