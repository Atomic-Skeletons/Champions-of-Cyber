extends Node2D

@onready var active_room: Node = %"Active Room"

func _ready() -> void:
	LevelManager.change_to_room.connect(change_room)


func change_room(room_path: String):
	Utilities.clear_all_children(active_room)
	
	var room_node = load(room_path)
	active_room.add_child(room_node)
	
	TransitionScreen.fade_out()
