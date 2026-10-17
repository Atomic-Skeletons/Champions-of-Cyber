extends Control


# all the grid children will have a script that has the character
# and the controller is going to communicating between the full art
# and the selection menu when each controller moves around
# one controller can have 2 ui input controllers

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func try_to_progress():
	LevelManager.continue_to_level()

func _on_player_1_characters_selected(character_1_id: int, character_2_id: int) -> void:
	PlayerInfo.p1_character1_id = character_1_id
	PlayerInfo.p1_character2_id = character_2_id
	try_to_progress()
