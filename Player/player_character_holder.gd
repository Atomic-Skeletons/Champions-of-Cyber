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
	phantom_camera.global_position = active_character.global_position

func _process(delta: float) -> void:
	if not active_character.air_movement:
		active_character.material.set_shader_parameter("saturation", .5)
	else:
		active_character.material.set_shader_parameter("saturation", 1)
	if active_character.is_action_just_pressed("tag"):
		tag()
		phantom_camera.follow_target = active_character

func tag():
	# Swap character with other based on index
	if active_character_index == 1:
		activate_character(character_2)
		update_new_character(character_2, character_1)
		deactivate_character(character_1)
		active_character = character_2
		active_character_index = 2
	
	elif active_character_index == 2:
		activate_character(character_1)
		update_new_character(character_1, character_2)
		deactivate_character(character_2)
		active_character = character_1
		active_character_index = 1
	

func update_new_character(new: Character, old: Character):
	new.velocity = old.velocity
	new.global_position = old.global_position
	new.facing_dir = old.facing_dir
	new.air_movement = old.air_movement

func activate_character(character: Character):
	character.show()
	character.process_mode = Node.PROCESS_MODE_INHERIT

func deactivate_character(character: Character):
	character.hide()
	character.process_mode = Node.PROCESS_MODE_DISABLED
