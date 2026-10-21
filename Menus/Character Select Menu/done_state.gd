extends LimboState


func _enter() -> void:
	# if all players have selected characters,
	# then go to the level
	var one_not_ready = false
	var controllers : Array = get_tree().get_nodes_in_group("Character Select Controller")
	for controller : CharacterSelectMenuController in controllers:
		if not controller.is_done():
			one_not_ready = true
	
	if not one_not_ready:
		agent.accepted_characters()

func _update(_delta: float) -> void:
	var input : UiInputHandlerTest = agent.input
	
	if input.is_action_just_pressed("accept"):
		agent.accepted_characters()
	if input.is_action_just_pressed("cancel"):
		get_root().dispatch("back")
