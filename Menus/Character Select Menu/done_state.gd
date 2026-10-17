extends LimboState


func _update(_delta: float) -> void:
	var input : UiInputHandlerTest = agent.input
	
	if input.is_action_just_pressed("accept"):
		agent.accepted_characters()
	if input.is_action_just_pressed("cancel"):
		get_root().dispatch("back")
