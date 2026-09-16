extends Area2D

@onready var phantom_camera: PhantomCamera2D = get_tree().get_first_node_in_group("Phantom Camera")

func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		phantom_camera.follow_mode = phantom_camera.FollowMode.GROUP
		phantom_camera.follow_targets = [get_parent(), Global.get_player().active_character]

func _on_body_exited(body: Node2D) -> void:
	if body is Character:
		phantom_camera.follow_mode = phantom_camera.FollowMode.SIMPLE
