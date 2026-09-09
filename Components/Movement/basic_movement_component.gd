class_name BasicMovementComponent extends MovementComponent

var jump_force = -300
var move_speed = 300

func move(body: CharacterBody2D, input_direction: Vector2, input_jump: bool, delta):
	# Add the gravity.
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta
	
	# Handle jump.
	if input_jump and body.is_on_floor():
		body.velocity.y = jump_force
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if input_direction:
		body.velocity.x = input_direction.x * move_speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, move_speed)
	
	body.move_and_slide()
