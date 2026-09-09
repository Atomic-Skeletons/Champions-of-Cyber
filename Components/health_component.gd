class_name HealthComponent extends Node

signal health_changed()
signal died()

var max_hp = 10
var current_hp = 10

func damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		died.emit()

func heal(amount):
	current_hp += amount
	current_hp = min(max_hp, current_hp)
