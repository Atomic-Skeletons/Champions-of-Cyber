class_name AttackData
extends Resource

enum damage_tag {
	fire,
	ice,
	electric,
	force
}

@export var damage: int = 10
@export var damage_tags: Array[damage_tag] = []

# knockback will be based on facing direction
@export_range(-180, 180) var knockback_angle: float
@export var knockback_strength: float

@export var hitstun_duration: float = .5
#@export var invincibility_duration: float = 1

@export var hitstop_duration: float = .1

func get_reversed_knockback_andle() -> AttackData:
	var new_attack_data := self.duplicate()
	
	# reverse the knockback angle
	new_attack_data.knockback_angle = 180 - knockback_angle
	
	return new_attack_data
