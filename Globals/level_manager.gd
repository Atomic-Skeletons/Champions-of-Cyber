extends Node

var next_level: StringName
var next_spawn: StringName = &""

func change_room(scene_path: String, spawn_name: StringName) -> void:
	next_spawn = spawn_name
	# Deferred, because this is usually called from a physics callback
	get_tree().change_scene_to_file.call_deferred(scene_path)


func open_level(path: String):
	pass

func open_room():
	pass
