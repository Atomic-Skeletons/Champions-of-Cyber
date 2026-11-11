extends LimboState


"""
The character will not be able to move for x duration
maybe there will be a tecking mechanic or they regain
control when they hit the ground, but that would be
easy to determine here
"""
var knockback_tween: Tween

var explorer: ExplorerTest
func _setup() -> void:
	explorer = agent

func _enter() -> void:
	# this needs to know the duration of the knockback
	# and the direction
	var cargo = get_cargo()
	
	# the vector of the knockback
	var vector = cargo[0]
	explorer.velocity = vector
	
	# knockback tween with the duration of the knockback
	knockback_tween = Utilities.reset_tween(knockback_tween, self)
	
	var duration = cargo[1]
	knockback_tween.tween_interval(duration)
	knockback_tween.tween_callback(recover)
	
	explorer.anim_player.play("recoil")

func _exit() -> void:
	knockback_tween.stop()

func _update(delta: float) -> void:
	if not explorer.is_on_floor():
		explorer.velocity += explorer.get_gravity() * delta
		
	# move with gravity through knockabck vector
	explorer.move_and_slide()
	
	# if they hit the ground then recover early?
	if explorer.is_on_floor():
		recover()

func recover():
	dispatch("recover")
