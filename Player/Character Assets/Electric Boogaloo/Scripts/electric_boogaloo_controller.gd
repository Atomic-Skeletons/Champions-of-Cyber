extends Character


@export var move_speed := 200
@export var jump_strength = -300.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := get_x_axis()
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
