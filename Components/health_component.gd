class_name HealthComponent extends Node

signal health_changed()
signal died()
signal knockback(vector: Vector2)

@export_category("Health")
@export var max_hp = 10
var current_hp = 10

@export_category("Tags")
@export var immunity_tags: Array[Data.damage_tag]
@export var weakness_tags: Array[Data.damage_tag]
## If this is set to true, only damage tags that match a weakness will deal damage.
## Useful for destructables that can only be damaged by a specific tag
@export var weakness_only_damage: bool

func _ready() -> void:
	current_hp = max_hp

func damage(amount: int, damage_tags: Array[Data.damage_tag], knockback_vector: Vector2):
	if can_damage(damage_tags):
		current_hp -= amount
		if knockback_vector:
			knockback.emit(knockback_vector * 10)
	if current_hp <= 0:
		died.emit()

func heal(amount):
	current_hp += amount
	current_hp = min(max_hp, current_hp)

func can_damage(damage_tags: Array[Data.damage_tag]) -> bool:
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
