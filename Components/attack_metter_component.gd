class_name AttackMetterComponent
extends Node

@export var max_metter: float = 100
var value : float

@export var normal_recharge_rate: float = 10
@export var out_recharge_rate: float = 20

var out = false

func _ready() -> void:
	value = max_metter

func _process(delta: float) -> void:
	if not out:
		gain_metter(normal_recharge_rate * delta)
	else:
		gain_metter(out_recharge_rate * delta)

func can_use_metter(amount: float) -> bool:
	if value < amount:
		return false
	return true

func use_metter(amount: float):
	value -= amount
	value = clamp(value, 0, max_metter)

func gain_metter(amount: float):
	value += amount
	value = clamp(value, 0, max_metter)
