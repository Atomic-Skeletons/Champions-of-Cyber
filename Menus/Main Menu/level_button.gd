extends Button


@export_file("*.tscn") var scene_name: String


func _ready() -> void:
	pressed.connect(open_level)

func open_level():
	LevelManager.open_level(scene_name)
