extends Node

signal change_to_room(scene_path: String)

const character_select_menu_uid = "uid://qwf08mxbvhth"

var next_level: String
var next_spawn: StringName = &""
var in_progress = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_room(scene_path: String, spawn_name: StringName = "Start") -> void:
	next_spawn = spawn_name
	
	# Deferred, because this is usually called from a physics callback
	get_tree().change_scene_to_file.call_deferred(scene_path)


func open_level(path: String):
	if in_progress: return
	start_transition()
	next_level = path
	
	await TransitionScreen.animation_done
	
	get_tree().change_scene_to_file(character_select_menu_uid)
	start_scene()

func continue_to_level():
	if in_progress: return
	start_transition()
	
	await TransitionScreen.animation_done
	
	change_room(next_level, next_spawn)
	start_scene()

func open_room(path: String, spawn_name: String):
	if in_progress: return
	start_transition()
	
	await TransitionScreen.animation_done
	
	change_room(path, spawn_name)
	start_scene()

func restart_room():
	if in_progress: return
	start_transition()
	
	await TransitionScreen.animation_done
	
	get_tree().reload_current_scene()
	start_scene()

func start_transition():
	in_progress = true
	TransitionScreen.reset_center()
	TransitionScreen.start_level_transition()

func start_scene():
	in_progress = false
	get_tree().paused = false
	TransitionScreen.reset_center()
	TransitionScreen.fade_out()
