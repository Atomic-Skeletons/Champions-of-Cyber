extends TextureProgressBar

@export var attack_metter_component: AttackMetterComponent

func _physics_process(delta: float) -> void:
	max_value = attack_metter_component.max_metter
	value = attack_metter_component.value
