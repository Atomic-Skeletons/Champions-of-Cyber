extends LimboState


var explorer: ExplorerTest
func _setup() -> void:
	explorer = agent

func _enter() -> void:
	explorer.anim_player.play("fall")

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	explorer.velocity += explorer.get_gravity() * delta
	explorer.velocity.y = min(explorer.velocity.y, explorer.terminal_velocity)
	
	var direction := explorer.input.get_x_axis()
	explorer.update_facing_direction(sign(direction))
	
	explorer.x_move(direction)
	
	explorer.move_and_slide()
	
	if explorer.is_on_floor():
		dispatch("landed")
