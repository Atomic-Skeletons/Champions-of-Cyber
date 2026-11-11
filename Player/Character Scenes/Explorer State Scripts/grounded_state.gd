extends LimboState

var explorer: Explorer
func _setup() -> void:
	explorer = agent.get_parent()

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	
	explorer.move_and_slide()
