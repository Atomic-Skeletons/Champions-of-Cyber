extends Node


const EXPLORER = preload("uid://7lw1yr2xg5ye")
const ELECTRIC_BOOGALOO = preload("uid://bfukd726rcgk2")
const ROLLER_SHARK = preload("uid://cb3g7rkvm3hel")


const character_order = [
	EXPLORER,
	ELECTRIC_BOOGALOO,
	ROLLER_SHARK
]


var p1_character1_id : int = 0
var p1_character2_id : int = 1

var p2_character1_id : int = 0
var p2_character2_id : int = 1


func get_character_from_id(id: int) -> PackedScene:
	return character_order[id]

func get_characters_from_player_id(id: int) -> Array[PackedScene]:
	var characters: Array[PackedScene] = []
	
	if id == 1:
		characters.append(get_character_from_id(p1_character1_id))
		characters.append(get_character_from_id(p1_character2_id))
	
	elif id == 2:
		characters.append(get_character_from_id(p2_character1_id))
		characters.append(get_character_from_id(p2_character2_id))
	
	return characters
