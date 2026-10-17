class_name UiInputHandlerTest
extends Node


enum InputSource { KEYBOARD, JOYPAD }

@export var input_source: InputSource = InputSource.KEYBOARD

var player_id: int:
	set(value):
		player_id = value
		update_input_data()

@export_range(1, 2) var player_index: int = 1

## Only used when input_source == JOYPAD.
@export var joypad_device: int = 0

## Controller button mapping. Change these if your pad's face buttons don't
## match Xbox-style layout (A = bottom face button, X = left face button).
@export var accept_button: JoyButton = JOY_BUTTON_A
@export var cancel_button: JoyButton = JOY_BUTTON_B
@export var joy_deadzone: float = 0.3

var _joy_now := {
	"left": false, "right": false, "up": false, "down": false,
	"accept": false, "cancel": false,
}
var _joy_prev := _joy_now.duplicate()

func _ready() -> void:
	process_physics_priority -= 1

func _physics_process(_delta: float) -> void:
	if input_source == InputSource.JOYPAD:
		_poll_joypad()


func _poll_joypad() -> void:
	_joy_prev = _joy_now.duplicate()

	var axis_x := Input.get_joy_axis(joypad_device, JOY_AXIS_LEFT_X)
	var axis_y := Input.get_joy_axis(joypad_device, JOY_AXIS_LEFT_Y)

	_joy_now["left"] = axis_x < -joy_deadzone or Input.is_joy_button_pressed(joypad_device, JOY_BUTTON_DPAD_LEFT)
	_joy_now["right"] = axis_x > joy_deadzone or Input.is_joy_button_pressed(joypad_device, JOY_BUTTON_DPAD_RIGHT)
	_joy_now["up"] = axis_y < -joy_deadzone or Input.is_joy_button_pressed(joypad_device, JOY_BUTTON_DPAD_UP)
	_joy_now["down"] = axis_y > joy_deadzone or Input.is_joy_button_pressed(joypad_device, JOY_BUTTON_DPAD_DOWN)
	_joy_now["accept"] = Input.is_joy_button_pressed(joypad_device, accept_button)
	_joy_now["cancel"] = Input.is_joy_button_pressed(joypad_device, cancel_button)

func _keyboard_action(action: String) -> String:
	return "p%d_%s" % [player_index, action]


func is_action_pressed(action: String) -> bool:
	if input_source == InputSource.KEYBOARD:
		return Input.is_action_pressed(_keyboard_action(action))
	return _joy_now.get(action, false)


func is_action_just_pressed(action: String) -> bool:
	if input_source == InputSource.KEYBOARD:
		return Input.is_action_just_pressed(_keyboard_action(action))
	return _joy_now.get(action, false) and not _joy_prev.get(action, false)


func is_action_just_released(action: String) -> bool:
	if input_source == InputSource.KEYBOARD:
		return Input.is_action_just_released(_keyboard_action(action))
	return _joy_prev.get(action, false) and not _joy_now.get(action, false)


## -1..1, same idea as Input.get_axis(left_action, right_action).
func get_x_axis() -> float:
	if input_source == InputSource.KEYBOARD:
		return Input.get_axis(_keyboard_action("left"), _keyboard_action("right"))
	var axis := Input.get_joy_axis(joypad_device, JOY_AXIS_LEFT_X)
	if absf(axis) > joy_deadzone:
		return axis
	return float(is_action_pressed("right")) - float(is_action_pressed("left"))


## -1..1 vertical axis (up = -1). Only useful if you add ladders/crouch later.
func get_y_axis() -> float:
	if input_source == InputSource.KEYBOARD:
		return Input.get_axis(_keyboard_action("up"), _keyboard_action("down"))
	var axis := Input.get_joy_axis(joypad_device, JOY_AXIS_LEFT_Y)
	if absf(axis) > joy_deadzone:
		return axis
	return float(is_action_pressed("down")) - float(is_action_pressed("up"))


func get_input_data() -> Dictionary:
	var input_data: Dictionary = {
		input_source = input_source,
		player_index = player_index,
		joypad_device = joypad_device
	}
	return input_data

func update_input_data():
	var input_data: Dictionary
	
	if player_id == 1:
		input_data = InputInfo.player_1_input_info
	if player_id == 2:
		input_data = InputInfo.player_2_input_info
	
	input_source = input_data.input_source
	player_index = input_data.player_index
	joypad_device = input_data.joypad_device
