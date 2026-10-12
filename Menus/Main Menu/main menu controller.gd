extends Control


func _on_quit_pressed() -> void:
	SaveDataController.save_game()
	get_tree().quit()


var last_focus_button: Button
@export var menus: Array[Control]

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
	for menu in menus:
		menu.hidden.connect(remove_top_menu_from_stack)


func pause():
	get_tree().paused = true
	show()
	#first button.grab_focus()

func unpause():
	get_tree().paused = false
	hide()


func _on_controller_setup_pressed() -> void:
	pass
	#add_menu_to_stack(controller_setup)
