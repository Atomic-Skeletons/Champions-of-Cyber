extends Area2D


@export_file("*.tscn") var target_scene: String
@export var target_spawn: StringName
@onready var interaction_indicator: Sprite2D = %"Interaction Indicator"


func _ready() -> void:
	interaction_indicator.hide()

func _process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	var input_handlers = []
	for body in bodies:
		if body is Character:
			input_handlers.append(body.input)
	
	for input: PlayerInputHandler in input_handlers:
		if input.is_action_just_pressed("up"):
			enter()
	
	if input_handlers.size() > 0:
		interaction_indicator.show()
	else:
		interaction_indicator.hide()

func enter():
	LevelManager.open_room(target_scene, target_spawn)
