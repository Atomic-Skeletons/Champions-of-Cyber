extends Node


var SAVE_FLAGS = preload("uid://cvpmbf1g6l0lk")
const save_file_path := "user://data.dat"


func _ready() -> void:
	load_game()

func load_game():
	if !FileAccess.file_exists(save_file_path):
		save_game()
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	var save_dictionary = JSON.parse_string(file.get_as_text())
	load_data_into_resource(SAVE_FLAGS, save_dictionary)
	file.close()

func save_game():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	var save_dictionary := get_save_dictionary()
	var jstr := JSON.stringify(save_dictionary)
	file.store_string(jstr)
	file.close()

func get_save_dictionary() -> Dictionary:
	return resource_to_dict(SAVE_FLAGS)


func resource_to_dict(res: Resource) -> Dictionary:
	var dict := {}
	for prop in res.get_property_list():
		# Filter out built-in engine properties and metadata
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			dict[prop.name] = res.get(prop.name)
	return dict

func load_data_into_resource(resource: Resource, data: Dictionary) -> void:
	for key in data:
		# Optional check: ensures the resource has this variable to avoid errors
		if key in resource:
			resource.set(key, data[key])
