class_name PlayerCharacterHolder extends Node2D

@export_range(1,2) var player_id: int = 1

var active_character: Character
var active_character_index = 1

var character_1: Character
var character_2: Character

@onready var character_1_scene: PackedScene = load(PlayerInfo.p1_character1_uid) if player_id == 1 else load(PlayerInfo.p2_character1_uid)
@onready var character_2_scene: PackedScene = load(PlayerInfo.p1_character2_uid) if player_id == 1 else load(PlayerInfo.p2_character2_uid)


@export var spawn_point: Marker2D

@onready var phantom_camera: PhantomCamera2D = Global.get_phantom_camera()


func _ready() -> void:
	if not character_1:
		character_1 = character_1_scene.instantiate()
		active_character = character_1
		add_child(character_1)
		character_1.input.player_id = player_id
		character_1.input.update_input_data()
		character_1.attack_metter_component.reparent(self)
	if not character_2:
		character_2 = character_2_scene.instantiate()
		add_child(character_2)
		character_2.input.player_id = player_id
		character_2.input.update_input_data()
		character_2.attack_metter_component.reparent(self)
		deactivate_character(character_2)
	
	#phantom_camera.follow_target = active_character
	active_character.global_position = spawn_point.global_position
	
	await get_tree().process_frame
	phantom_camera.teleport_position()


func _physics_process(_delta: float) -> void:
	phantom_camera.follow_offset.x = abs(phantom_camera.follow_offset.x) * active_character.facing_dir
	
	if not active_character.air_movement:
		active_character.material.set_shader_parameter("saturation", .5)
	else:
		active_character.material.set_shader_parameter("saturation", 1)
	
	if active_character.input.is_action_just_pressed("tag"):
		tag()
	
	if active_character.is_on_floor():
		character_1.air_movement = true
		character_2.air_movement = true

func tag():
	if not active_character.can_tag: return
	# Swap character with other based on index
	# if the first character is active
	if active_character_index == 1:
		update_new_character(character_2, character_1)
		deactivate_character(character_1)
		activate_character(character_2)
		active_character = character_2
		active_character_index = 2
	
	# if the second character is active
	elif active_character_index == 2:
		update_new_character(character_1, character_2)
		deactivate_character(character_2)
		activate_character(character_1)
		active_character = character_1
		active_character_index = 1
	
	# I need to make it so after tagging the player gets a frame
	# of invulnerability so they spawn without triggering the
	# old position

func update_new_character(new: Character, old: Character):
	new.velocity = old.velocity
	new.global_position = old.global_position
	new.facing_dir = old.facing_dir

func activate_character(character: Character):
	character.show()
	character.attack_metter_component.out = false
	character.process_mode = Node.PROCESS_MODE_INHERIT
	# makes the player not interact with enemies until a short delay
	# after tagging in
	Utilities.disable_enemy_collision(character)
	await get_tree().create_timer(.1, false, true).timeout
	Utilities.enable_enemy_collision(character)

func deactivate_character(character: Character):
	character.hide()
	character.attack_metter_component.out = true
	character.process_mode = Node.PROCESS_MODE_DISABLED
