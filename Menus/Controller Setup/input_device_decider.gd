class_name InputDeviceHolder
extends MarginContainer

# These are the destinations when those are selected
@export var player_1_container: Control
@export var player_2_container: Control
@onready var init_parent

@onready var left_arrow: Label = %"Left Arrow"
@onready var right_arrow: Label = %"Right Arrow"


enum input_menu_states {
	NONE,
	P1,
	P2
}

var input_menu_state: input_menu_states = input_menu_states.NONE

@export_range(-1, 2) var joypad_index: int
var joypad_id = null

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	init_parent = get_parent()
	update_controllers()

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if device == joypad_id:
		if not connected:
			print("Controller disconnected from index: ", device)

func update_controllers():
	var connected_joypads = Input.get_connected_joypads()
	if joypad_index != -1:
		if joypad_index < connected_joypads.size():
			show()
			joypad_id = connected_joypads[joypad_index]
		else:
			hide()

func _unhandled_input(event: InputEvent) -> void:
	# if they press a button and it's the right controller
	# then make it appear rather than move it
	
	# if keyboard
	if joypad_index == -1:
		if event is InputEventKey and event.pressed:
			var direction = Input.get_axis("left", "right")
			if direction == 1:
				move_right()
			elif direction == -1:
				move_left()
	else:
		# checking if input was from this index's device
		if (event is InputEventJoypadButton and event.pressed) or event is InputEventJoypadMotion:
			var controller_id = event.device
			if controller_id == joypad_index:
				if not visible:
					show()
				else:
					if event is InputEventJoypadMotion:
						var deadzone = 1
						var axis_value = event.axis_value
						if axis_value >= deadzone:
							move_right()
						elif axis_value <= -deadzone:
							move_left()

func set_input_menu_state(state: input_menu_states):
	input_menu_state = state
	
	if state == input_menu_states.NONE:
		reparent(init_parent, false)
		left_arrow.show()
		right_arrow.show()
	
	elif state == input_menu_states.P1:
		reparent(player_1_container, false)
		left_arrow.hide()
	
	elif state == input_menu_states.P2:
		reparent(player_2_container, false)
		right_arrow.hide()

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
