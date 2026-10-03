extends Control


@onready var resume: Button = %Resume
var last_focus_button: Button
@onready var controller_setup: Control = %"Controller Setup"

var menu_stack: Array[Control] = []


func add_menu_to_stack(node: Control):
	if menu_stack.size() == 0:
		last_focus_button = get_viewport().gui_get_focus_owner()
	node.show()
	disable_top_menu()
	menu_stack.append(node)

var im_hiding = false
func remove_top_menu_from_stack():
	if im_hiding:
		im_hiding = false
		return
	if menu_stack.size() == 0:
		unpause()
	else:
		var top_menu = menu_stack.pop_back()
		if top_menu.visible:
			im_hiding = true
			top_menu.hide()
		enable_top_menu()

func disable_top_menu():
	if menu_stack.size() == 0:
		focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	else:
		menu_stack[-1].focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func enable_top_menu():
	if menu_stack.size() == 0:
		focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
		last_focus_button.grab_focus()
	else:
		menu_stack[-1].focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	controller_setup.hidden.connect(remove_top_menu_from_stack)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var paused = get_tree().paused
	if Input.is_action_just_pressed("pause"):
		if paused:
			remove_top_menu_from_stack()
		else:
			pause()


func pause():
	get_tree().paused = true
	show()
	resume.grab_focus()

func unpause():
	get_tree().paused = false
	hide()


func _on_controller_setup_pressed() -> void:
	add_menu_to_stack(controller_setup)


func _on_toggle_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_save_game_pressed() -> void:
	SaveDataController.save_game()
