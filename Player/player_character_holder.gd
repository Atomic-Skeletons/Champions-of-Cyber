class_name PlayerCharacterHolder extends Node

var active_character: Character
var active_character_index = 1

var character_1: Character
var character_2: Character

@export var character_1_scene: PackedScene
@export var character_2_scene: PackedScene

@export var spawn_point: Marker2D

@onready var phantom_camera: PhantomCamera2D = Global.get_phantom_camera()

func _ready() -> void:
	if not character_1:
		character_1 = character_1_scene.instantiate()
		active_character = character_1
		add_child(character_1)
	if not character_2:
		character_2 = character_2_scene.instantiate()
		add_child(character_2)
		deactivate_character(character_2)
	
	phantom_camera.follow_target = active_character
	active_character.global_position = spawn_point.global_position

func _process(delta: float) -> void:
	if active_character.is_action_just_pressed("tag"):
		tag()
		phantom_camera.follow_target = active_character

func tag():
	var old_char_global_position = active_character.global_position
	var old_char_velocity = active_character.velocity
	
	# Swap character with other based on index
	if active_character_index == 1:
		deactivate_character(character_1)
		activate_character(character_2)
		active_character = character_2
		active_character_index = 2
	
	elif active_character_index == 2:
		deactivate_character(character_2)
		activate_character(character_1)
		active_character = character_1
		active_character_index = 1
	
	active_character.velocity = old_char_velocity
	active_character.global_position = old_char_global_position

func activate_character(character: Character):
	character.show()
	character.process_mode = Node.PROCESS_MODE_INHERIT

func deactivate_character(character: Character):
	character.hide()
	character.process_mode = Node.PROCESS_MODE_DISABLED
