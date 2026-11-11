extends LimboState


var hitstun_tween: Tween
var knockback_data

var explorer: ExplorerTest
func _setup() -> void:
	explorer = agent

func _enter() -> void:
	hitstun_tween = Utilities.reset_tween(hitstun_tween, self)
	
	var cargo = get_cargo()
	var duration = cargo[0]
	
	hitstun_tween.tween_interval(duration)
	hitstun_tween.tween_callback(end_hitstun)
	
	knockback_data = cargo[1]
	
	explorer.anim_player.play("recoil")

func _exit() -> void:
	hitstun_tween.stop()

func end_hitstun():
	dispatch("knockback", knockback_data)
