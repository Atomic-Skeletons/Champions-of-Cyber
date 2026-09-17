extends Node


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
