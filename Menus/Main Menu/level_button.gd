extends Button


@export var scene_name: String


func _ready() -> void:
	pressed.connect(open_level)

func open_level():
	get_tree().change_scene_to_file(scene_name)
