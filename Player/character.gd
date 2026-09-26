class_name Character extends CharacterBody2D

@onready var input: PlayerInputHandler = get_input_handler_node()

var facing_dir: int = 1
var air_movement := true
var can_tag := true

func get_input_handler_node() -> PlayerInputHandler:
	for child in get_children():
		if child is PlayerInputHandler:
			return child
	return null
