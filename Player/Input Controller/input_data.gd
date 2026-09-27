class_name InputData
extends Resource


var input_source: PlayerInputHandler.InputSource = PlayerInputHandler.InputSource.KEYBOARD


var player_index: int = 1

var joypad_device: int = 0

var jump_button: JoyButton = JOY_BUTTON_A
var attack_button: JoyButton = JOY_BUTTON_X
var tag_button: JoyButton = JOY_BUTTON_Y
var joy_deadzone: float = 0.3

var _joy_now := {
	"left": false, "right": false, "up": false, "down": false,
	"jump": false, "attack": false,
}
var _joy_prev := _joy_now.duplicate()
