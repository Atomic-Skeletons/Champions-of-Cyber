extends Control

@onready var active_controllers: VBoxContainer = %"Active Controllers Holder"
var max_controller_count: int = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_controller_count = active_controllers.get_child_count()-1


@onready var player_1_container: MarginContainer = %"Player 1 Container"
@onready var player_2_container: MarginContainer = %"Player 2 Container"

#@onready var keyboard_controller: VBoxContainer = %"Keyboard Controller"

var player_1_controller = -1
var player_2_controller = 0




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	
	for i in range(max_controller_count):
		active_controllers.get_child(i+1).hide()
	
	var connected_joypads = Input.get_connected_joypads()
	
	for i in range(min(connected_joypads.size(), max_controller_count)):
		var connected_joypad = connected_joypads[i]
		active_controllers.get_child(i+1).show()
	
	
	# Keyboard
	var direction = Input.get_axis("left", "right")
	#if direction:
		#keyboard_controller.reparent(player_1_container)


func is_player_container_filled(control: Control) -> bool:
	if control.get_child_count() == 0:
		return true
	return false
