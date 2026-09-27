extends Control

@onready var controller_setup: Control = %"Controller Setup"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible

func pause():
	get_tree().paused = true
	show()

func unpause():
	get_tree().paused = false
	hide()


func _on_controller_setup_pressed() -> void:
	pass
