extends Control


# all the grid children will have a script that has the character
# and the controller is going to communicating between the full art
# and the selection menu when each controller moves around
# one controller can have 2 ui input controllers

@onready var input_p1: UiInputHandler = $UiInputHandler
@onready var input_p2: UiInputHandler = $UiInputHandler2



func _ready() -> void:
	input_p1.player_id = 1
	input_p1.update_input_data()
	input_p2.player_id = 2
	input_p2.update_input_data()


func _process(delta: float) -> void:
	pass
