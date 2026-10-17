extends LimboState


func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _ready() -> void:
	pass

func _update(_delta: float) -> void:
	if agent.input.is_action_just_pressed("cancel"):
		get_root().dispatch("back")
