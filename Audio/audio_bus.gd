extends Node


const MENU_MUSIC = null
const FOREST_MUSIC = preload("uid://b6t02ephemuwp")
const CAVE_MUSIC = null

enum music_states {
	menu,
	forest,
	cave
}
var music_state = music_states.menu
var music_volume: float

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_menu():
	# if music is already forest, then don't change
	if music_state == music_states.menu: return
	
	music_state = music_states.menu
	Stoat.play_music(MENU_MUSIC)

func set_forest():
	# if music is already forest, then don't change
	if music_state == music_states.forest: return
	
	music_state = music_states.forest
	Stoat.play_music(FOREST_MUSIC)

func set_cave():
	# if music is already forest, then don't change
	if music_state == music_states.cave: return
	
	music_state = music_states.cave
	Stoat.play_music(CAVE_MUSIC)

func fade_in_music(duration: float):
	pass

func fade_out_music(duration: float):
	pass
