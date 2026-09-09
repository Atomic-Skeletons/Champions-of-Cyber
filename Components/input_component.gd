class_name InputComponent extends Node

var pressed_jump = false
var pressed_attack = false
var pressed_swap = false
var direction = Vector2.ZERO

func update_inputs():
	pressed_jump = Input.is_action_just_pressed("jump")
	
	pressed_attack = Input.is_action_just_pressed("attack")
	
	pressed_swap = Input.is_action_just_pressed("swap")
	
	direction = Input.get_vector("left", "right", "down", "up")
