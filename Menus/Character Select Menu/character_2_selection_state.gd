extends LimboState


func _enter() -> void:
	pass

func _ready() -> void:
	pass

func _update(_delta: float) -> void:
	var input : UiInputHandlerTest = agent.input
	
	if input.is_action_just_pressed("accept"):
		get_root().dispatch("character_selected")
	
	elif input.is_action_just_pressed("cancel"):
		agent.deselect_character_2()
		get_root().dispatch("back")
	
	else:
		if input.is_action_just_pressed("right"): agent.move(2, Vector2i.RIGHT)
		if input.is_action_just_pressed("left"): agent.move(2, Vector2i.LEFT)
		if input.is_action_just_pressed("up"): agent.move(2, Vector2i.UP)
		if input.is_action_just_pressed("down"): agent.move(2, Vector2i.DOWN)
