class_name InputHandler
extends CharacterBody2D
## Reusable per-player input reader for local co-op.
##
## Attach ONE instance of this as a child of each Player (e.g. name it
## "InputHandler"). Configure `input_source` + `player_index` (keyboard) or
## `joypad_device` (controller) in the Inspector, then in your Player script
## call is_action_pressed()/is_action_just_pressed()/get_move_axis() instead
## of calling Input.* directly. Everything else about the player script stays
## the same regardless of which device is driving it.

enum InputSource { KEYBOARD, JOYPAD }

@export var input_source: InputSource = InputSource.KEYBOARD

## Only used when input_source == KEYBOARD.
## Selects between the "p1_*" / "p2_*" actions defined in Project Settings
## -> Input Map (see SETUP.md).
@export_range(1, 2) var player_index: int = 1

## Only used when input_source == JOYPAD.
## Index into Input.get_connected_joypads(): 0 = first controller plugged
## in, 1 = second, etc. This is what actually separates "P1 controller" from
## "P2 controller" -- the Input Map alone can't do that.
@export var joypad_device: int = 0

## Controller button mapping. Change these if your pad's face buttons don't
## match Xbox-style layout (A = bottom face button, X = left face button).
@export var jump_button: JoyButton = JOY_BUTTON_A
@export var attack_button: JoyButton = JOY_BUTTON_X
@export var tag_button: JoyButton = JOY_BUTTON_Y
@export var joy_deadzone: float = 0.3

var _joy_now := {
	"left": false, "right": false, "up": false, "down": false,
	"jump": false, "attack": false,
}
var _joy_prev := _joy_now.duplicate()


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
	_joy_now["jump"] = Input.is_joy_button_pressed(joypad_device, jump_button)
	_joy_now["attack"] = Input.is_joy_button_pressed(joypad_device, attack_button)
	_joy_now["tag"] = Input.is_joy_button_pressed(joypad_device, tag_button)

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
