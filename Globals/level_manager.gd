extends Node

signal change_to_room(scene_path: String)

var next_level: StringName
var next_spawn: StringName = &""
var in_progress = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_room(scene_path: String, spawn_name: StringName = "Start") -> void:
	next_spawn = spawn_name
	
	in_progress = false
	
	# Deferred, because this is usually called from a physics callback
	get_tree().change_scene_to_file.call_deferred(scene_path)
	
	get_tree().paused = false
	
	TransitionScreen.reset_center()
	TransitionScreen.fade_out()


func open_level(path: String):
	if in_progress: return
	in_progress = true
	TransitionScreen.reset_center()
	TransitionScreen.start_level_transition()
	await TransitionScreen.animation_done
	change_room(path)

func open_room(path: String, spawn_name: String):
	if in_progress: return
	in_progress = true
	TransitionScreen.reset_center()
	TransitionScreen.start_level_transition()
	await TransitionScreen.animation_done
	change_room(path, spawn_name)

func restart_room():
	if in_progress: return
	in_progress = true
	TransitionScreen.reset_center()
	TransitionScreen.start_level_transition()
	await TransitionScreen.animation_done
	get_tree().reload_current_scene()
	in_progress = false
	get_tree().paused = false
	TransitionScreen.reset_center()
	TransitionScreen.fade_out()
