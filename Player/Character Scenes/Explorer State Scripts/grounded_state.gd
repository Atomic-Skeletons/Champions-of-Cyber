extends LimboState

var explorer: ExplorerTest
func _setup() -> void:
	explorer = agent

func _enter() -> void:
	explorer.anim_player.play("idle")

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	if not explorer.is_on_floor():
		dispatch("falling")
	
	if explorer.input.is_action_just_pressed("jump"):
		dispatch("jumped")
	
	var direction := explorer.input.get_x_axis()
	explorer.update_facing_direction(sign(direction))
	
	if direction and explorer.velocity.x:
		explorer.anim_player.play("walk")
	else:
		explorer.anim_player.play("idle")
	
	explorer.x_move(direction)
	
	explorer.move_and_slide()
