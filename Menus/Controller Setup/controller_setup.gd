extends Control

#idea is to create a global ui handler node that listens to all keyboards and controllers

@onready var player_1_container: MarginContainer = %"Player 1 Container"
@onready var player_2_container: MarginContainer = %"Player 2 Container"

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		hide()


func _on_visibility_changed() -> void:
	var child = get_child(0)
	if visible:
		child.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		child.process_mode = Node.PROCESS_MODE_DISABLED
