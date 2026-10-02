class_name AttackMetterComponent
extends Node

@export var max_metter: float = 100
var value : float


func _ready() -> void:
	value = max_metter

func can_use_metter(amount: float) -> bool:
	if value < amount:
		return false
	return true

func use_metter(amount: float):
	value -= amount
	value = clamp(value, 0, max_metter)

func gain_metter(amount: float):
	value -= amount
	value = clamp(value, 0, max_metter)
