extends Node


func get_closest_character(node: Node2D) -> Character:
	var closest_character: Character
	
	for player_holder: PlayerCharacterHolder in get_tree().get_nodes_in_group("Player"):
		# if there wasn't a closest character yet
		if not closest_character:
			closest_character = player_holder.active_character
		# if there was one, calculate which one is closer
		else:
			var old_distance = abs(node.global_position - closest_character.global_position)
			var new_distance = abs(node.global_position - player_holder.active_character.global_position)
			if new_distance < old_distance:
				closest_character = player_holder.active_character
	
	return closest_character

func get_player() -> PlayerCharacterHolder:
	var player: PlayerCharacterHolder = get_tree().get_first_node_in_group("Player")
	return player

func get_phantom_camera() -> PhantomCamera2D:
	var phantom_camera: PhantomCamera2D = get_tree().get_first_node_in_group("Phantom Camera")
	return phantom_camera

func get_health_component(node: Node) -> HealthComponent:
	var health_component: HealthComponent = null
	
	if "health_component" in node:
		health_component = node.health_component
	
	return health_component
