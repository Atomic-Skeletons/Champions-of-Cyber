extends Character


const SPEED = 100.0
const JUMP_VELOCITY = -300.0
@export var laser_duration: float = .5

@onready var laser_start_point: Marker2D = %"Laser Start Point"
@onready var laser_raycast: RayCast2D = %"Laser Raycast"
@onready var laser_line: Line2D = %"Laser Line"
@onready var laser_hitbox: Hitbox = %"Laser Hitbox"


@onready var fliproot: Node2D = $Fliproot


func _ready() -> void:
	laser_hitbox.reparent(get_parent())
	laser_hitbox.global_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		air_movement = true
	# Handle jump.
	if is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif air_movement:
			air_movement = false
			velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := get_x_axis()
	if direction:
		update_facing_direction(direction)
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if is_action_just_pressed("attack"):
		shoot_laser_with_raycast_node()

func update_facing_direction(dir: int):
	facing_dir = sign(dir)
	fliproot.scale.x = sign(dir)

func shoot_laser_with_raycast_node():
	# duplicate the base visual indicator node and resets its position
	var line: Line2D = laser_line.duplicate()
	get_parent().add_child(line)
	line.global_position = Vector2.ZERO
	
	var start_point = laser_start_point.global_position
	
	# if the raycast is not hitting anything, it will default to
	# 1000 pixels in front of the player to create a laser to
	var end_point: Vector2 = laser_start_point.global_position
	end_point.x += 1000 * facing_dir
	
	# force the raycast to update so it's collisions are up to date
	laser_raycast.force_raycast_update()
	if laser_raycast.is_colliding():
		# if the raycast is colliding with anything, 
		# add that point as the end point
		end_point = laser_raycast.get_collision_point()
	
	# add the start and end points to the line
	line.add_point(start_point)
	line.add_point(end_point)
	
	# create a tween
	var tween: Tween = get_tree().create_tween()
	# waits a short amount of time before the laser starts to disapear
	tween.tween_interval(.2)
	# the tween will move the laser's alpha to 0 in an amount of time
	tween.tween_property(line, "self_modulate:a", 0, .3)
	# then after the alpha reaches 0, it will delete the laser line visual
	tween.tween_callback(func(): line.queue_free())
	
	
	# create the collision polygon to hit enemies
	var collision_polygon := CollisionPolygon2D.new()
	laser_hitbox.add_child(collision_polygon)
	end_point += Vector2(10*facing_dir, 0)
	var width := line.width * 4
	collision_polygon.polygon = [
		start_point + Vector2(0, -width), # top left
		end_point + Vector2(0, -width),   # top right
		end_point + Vector2(0, width),    # bottom right
		start_point + Vector2(0, width),  # bottom left
		]
	
	var collision_tween := get_tree().create_tween()
	collision_tween.tween_interval(laser_duration)
	tween.tween_callback(func(): collision_polygon.queue_free())
