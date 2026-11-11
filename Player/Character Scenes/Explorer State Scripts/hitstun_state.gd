extends LimboState


var hitstun_tween: Tween

func _setup() -> void:
	pass

func _enter() -> void:
	hitstun_tween = Utilities.reset_tween(hitstun_tween, self)
	#anim_play("recoil")

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass
