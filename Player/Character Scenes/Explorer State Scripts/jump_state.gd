extends LimboState


var explorer: ExplorerTest
func _setup() -> void:
	explorer = agent

func _enter() -> void:
	explorer.anim_player.play("jump")
	explorer.velocity.y -= 300

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	explorer.velocity += explorer.get_gravity() * delta
	
	var direction := explorer.input.get_x_axis()
	explorer.update_facing_direction(sign(direction))
	
	explorer.x_move(direction)
	
	explorer.move_and_slide()
	
	if explorer.velocity.y >= 0:
		dispatch("falling")
