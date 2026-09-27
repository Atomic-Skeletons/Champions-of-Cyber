class_name InputDeviceHolder
extends MarginContainer

var input: UiInputHandler

# These are the destinations when those are selected
@onready var player_1_container: MarginContainer = %"Player 1 Container"
@onready var player_2_container: MarginContainer = %"Player 2 Container"

@onready var init_parent

@onready var left_arrow: Label = %"Left Arrow"
@onready var right_arrow: Label = %"Right Arrow"


enum input_menu_states {
	NONE,
	P1,
	P2
}

var input_menu_state: input_menu_states = input_menu_states.NONE


func _ready() -> void:
	# get first child ui input handler if it exists
	for child in get_children():
		if child is UiInputHandler:
			input = child
	if input.input_source == input.InputSource.JOYPAD:
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
	init_parent = get_parent()
	update_visual()

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if device == input.joypad_device:
		# if the device is disconnected, move it back to the center
		if not connected:
			set_input_menu_state(input_menu_states.NONE)
		update_visual()

func update_visual():
	if input.input_source == input.InputSource.KEYBOARD: return
	
	var connected = is_joypad_connected()
	
	if connected:
		show()
	else:
		hide()

func is_joypad_connected() -> bool:
	var connected_joypads = Input.get_connected_joypads()
	
	# if my joypad index is connected return true
	for i in connected_joypads:
		if i == input.joypad_device:
			return true
	
	return false

func _physics_process(delta: float) -> void:
	if input.is_action_just_pressed("left"):
		move_left()
	elif input.is_action_just_pressed("right"):
		move_right()


func set_input_menu_state(state: input_menu_states):
	input_menu_state = state
	
	if state == input_menu_states.NONE:
		reparent(init_parent, false)
		left_arrow.show()
		right_arrow.show()
	
	elif state == input_menu_states.P1:
		reparent(player_1_container, false)
		left_arrow.hide()
		update_global_input_data()
	
	elif state == input_menu_states.P2:
		reparent(player_2_container, false)
		right_arrow.hide()
		update_global_input_data()

func move_left():
	if input_menu_state == input_menu_states.NONE and not is_player_container_filled(player_1_container):
		set_input_menu_state(input_menu_states.P1)
	
	if input_menu_state == input_menu_states.P2:
		set_input_menu_state(input_menu_states.NONE)

func move_right():
	if input_menu_state == input_menu_states.NONE and not is_player_container_filled(player_2_container):
		set_input_menu_state(input_menu_states.P2)
	
	if input_menu_state == input_menu_states.P1:
		set_input_menu_state(input_menu_states.NONE)

func is_player_container_filled(control: Control) -> bool:
	var has_child = false
	if control.get_child_count() >= 1:
		has_child = true
	return has_child

func update_global_input_data():
	if input_menu_state == input_menu_states.P1:
		InputInfo.player_1_input_info = input.get_input_data()
	elif input_menu_state == input_menu_states.P2:
		InputInfo.player_2_input_info = input.get_input_data()
