extends LimboState



func _enter() -> void:
	pass

func _ready() -> void:
	pass

# Runs every frame only if in this state
func _update(_delta: float) -> void:
	var input: UiInputHandlerTest = agent.input
	
	if input.is_action_just_pressed("accept"):
		get_root().dispatch("character_selected")
	
	else:
		if input.is_action_just_pressed("right"): agent.move(1, Vector2i.RIGHT)
		if input.is_action_just_pressed("left"): agent.move(1, Vector2i.LEFT)
		if input.is_action_just_pressed("up"): agent.move(1, Vector2i.UP)
		if input.is_action_just_pressed("down"): agent.move(1, Vector2i.DOWN)
