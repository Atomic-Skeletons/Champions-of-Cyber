class_name PlayerDetectionCast
extends RayCast2D

signal saw_character(character: Character)

var active = true

func _process(_delta: float) -> void:
	if not active: return
	
	var target = Global.get_closest_character(self)
	# look at the closest player
	look_at(target.global_position)
	
	if is_colliding():
		var collider = get_collider()
		if collider is Character:
			saw_character.emit(collider)
			active = false
