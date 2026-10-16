extends Node


const EXPLORER = preload("uid://7lw1yr2xg5ye")
const ELECTRIC_BOOGALOO = preload("uid://bfukd726rcgk2")
const ROLLER_SHARK = preload("uid://cb3g7rkvm3hel")


const character_order = [
	EXPLORER,
	ELECTRIC_BOOGALOO,
	ROLLER_SHARK
]


var p1_character1_id : int
var p1_character2_id : int

var p2_character1_id : int
var p2_character2_id : int


func get_character_from_id(id: int) -> PackedScene:
	return character_order[id]
