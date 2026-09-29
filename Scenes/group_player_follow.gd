extends Marker2D


func _ready() -> void:
	move_to_middle_position()

func _physics_process(delta: float) -> void:
	move_to_middle_position()

func move_to_middle_position():
	var player_holders = get_tree().get_nodes_in_group("Player")
	
	var follow_targets: Array[Character]
	
	for player_holder: PlayerCharacterHolder in player_holders:
		follow_targets.append(player_holder.active_character)
	
	if follow_targets.size() == 1:
		var player_position = follow_targets[0].global_position
		global_position = player_position
	
	else:
		var rect: Rect2 = Rect2(follow_targets[0].global_position, Vector2.ZERO)
		for target in follow_targets:
			rect = rect.expand(target.global_position)
		
		global_position = rect.get_center()
		
		Global.get_phantom_camera().follow_offset = Vector2.ZERO
