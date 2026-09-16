class_name Player
extends PlayerInputHandler

@export var character_1: PackedScene
@export var character_2: PackedScene

var character: PlayerInputHandler
var character_index: int = 1

func _ready() -> void:
	spawn(character_index)


func _process(delta: float) -> void:
	if is_action_just_pressed("tag"):
		tag()


func tag():
	if character_index == 1:
		character_index = 2
	else:
		character_index = 1
	spawn(character_index)

func spawn(index):
	for child in get_children():
		child.queue_free()
	
	if index == 1:
		character = character_1.instantiate()
	if index == 2:
		character = character_2.instantiate()
	
	for child in character.get_children():
		child.reparent(self, false)
	#character.global_position = global_position
