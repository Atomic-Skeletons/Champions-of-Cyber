extends FlowContainer

signal level_button_clicked(selected_item)

@export_dir var level_directory: String

var selected_level: String

var items : Array[String]:
	set(value):
		
		items = value
		
		var button_to_dupe: Button = get_child(0)
		var button: Button
		
		for filename in items:
			button = button_to_dupe.duplicate()
			button.text = filename.substr((level_directory+"/").length(), filename.find(".tscn")-(level_directory+"/").length())
			button.pressed.connect(func(): open_level(filename))
			
			add_child(button)
		button_to_dupe.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items = load_data_from_directory()


func load_data_from_directory() -> Array[String]:
	var directory = DirAccess.open(level_directory)
	var filenames: Array[String] = []
	
	if directory:
		var filename
		
		directory.list_dir_begin()
		
		filename = directory.get_next()
		
		while filename != "":
			if not directory.current_is_dir():
				filenames.append(level_directory+"/"+filename)
			
			filename = directory.get_next()
	
	return filenames


func open_level(level_path) -> void:
	if level_path != "":
		LevelManager.open_level(level_path)
