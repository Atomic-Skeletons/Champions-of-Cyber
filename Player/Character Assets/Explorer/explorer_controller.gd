extends Character


@export var move_speed = 100.0
@export var jump_strength = 300.0
@export var laser_duration: float = .5

@onready var laser_start_point: Marker2D = %"Laser Start Point"
@onready var laser_raycast: RayCast2D = %"Laser Raycast"
@onready var laser_line: Line2D = %"Laser Line"
@onready var laser_hitbox: Hitbox = %"Laser Hitbox"

@export var laser_bullet_scene: PackedScene
@export var laser_bullet_speed: float = 100

@onready var fliproot: Node2D = $Fliproot

@onready var anim_sprite: AnimatedSprite2D = $Fliproot/AnimatedSprite2D

var laser_charge_duration = .4
var laser_charge = 0
var mega_laser = false

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
			velocity.y = -jump_strength
		elif air_movement:
			air_movement = false
			velocity.y = -jump_strength
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := get_x_axis()
	if direction:
		update_facing_direction(direction)
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
	
	if is_action_pressed("attack"):
		anim_sprite.play("attack")
		laser_charge += delta
		if not mega_laser and laser_charge >= laser_charge_duration:
			start_mega_laser()
		if mega_laser:
			update_mega_laser()
	
	if is_action_just_released("attack"):
		laser_charge = 0
		if mega_laser:
			end_mega_laser()
		else:
			shoot_laser_bullet()
			anim_sprite.stop()
		anim_sprite.play("idle")

func update_facing_direction(dir: int):
	facing_dir = sign(dir)
	fliproot.scale.x = sign(dir)

func shoot_laser_bullet():
	var laser_bullet: RigidBody2D = laser_bullet_scene.instantiate()
	get_parent().add_child(laser_bullet)
	
	laser_bullet.global_position = laser_start_point.global_position
	laser_bullet.global_position.x += 15 * facing_dir
	laser_bullet.linear_velocity = Vector2(facing_dir*laser_bullet_speed, 0)


@onready var laser_pieces: Node2D = $"Fliproot/Laser Pieces"
@onready var start_marker: Marker2D = %"Start Marker"
@onready var end_marker: Marker2D = %"End Marker"
@onready var laser_collision_polygon: CollisionPolygon2D = %"Laser Collision Polygon"
@onready var laser_end: Sprite2D = %"Laser End"
@onready var mega_laser_shake: PhantomCameraNoiseEmitter2D = $"Mega Laser Shake"

func start_mega_laser():
	mega_laser = true
	laser_pieces.show()
	laser_line.show()
	laser_collision_polygon.disabled = false
	mega_laser_shake.emit()

func end_mega_laser():
	mega_laser = false
	laser_pieces.hide()
	laser_line.hide()
	laser_collision_polygon.disabled = true
	mega_laser_shake.stop(true)

func update_mega_laser():
	
	# base point if there is no collision
	var collision_point := laser_raycast.global_position + laser_raycast.target_position * facing_dir
	# force raycast to update collision
	laser_raycast.force_raycast_update()
	if laser_raycast.is_colliding():
		collision_point = laser_raycast.get_collision_point()
	
	laser_end.position = fliproot.to_local(collision_point)
	
	laser_line.clear_points()
	
	# add the start and end points to the line
	laser_line.add_point(laser_line.to_local(start_marker.to_global(Vector2.ZERO)))
	laser_line.add_point(laser_line.to_local(end_marker.to_global(Vector2.ZERO)))
	
	
	var end_point = collision_point
	#end_point.x += 1
	var width := laser_line.width/2
	
	
	var top_left = laser_collision_polygon.to_local(laser_start_point.global_position + Vector2(0, -width))
	var top_right = end_point + Vector2(0, -width)
	var bottom_right = end_point + Vector2(0, width)
	var bottom_left = laser_collision_polygon.to_local(laser_start_point.global_position + Vector2(0, width))
	
	laser_collision_polygon.polygon = [top_left, top_right, bottom_right, bottom_left]

func shoot_laser_with_raycast_node():
	# if the raycast is not hitting anything, it will default to
	# 160 pixels in front of the player to create a laser to
	var end_point: Vector2 = laser_start_point.global_position
	end_point.x += 160 * facing_dir
	
	# force the raycast to update so it's collisions are up to date
	laser_raycast.force_raycast_update()
	if laser_raycast.is_colliding():
		# if the raycast is colliding with anything, 
		# add that point as the end point
		end_point = laser_raycast.get_collision_point()
	
	laser_end.global_position = end_point
	
	laser_line.clear_points()
	# add the start and end points to the line
	laser_line.add_point(start_marker.position)
	laser_line.add_point(end_marker.position)
	
	
	# create the collision polygon to hit enemies
	end_point += Vector2(10*facing_dir, 0)
	var width := laser_line.width * 2
	laser_collision_polygon.polygon = [
		laser_start_point.global_position + Vector2(0, -width), # top left
		end_point + Vector2(0, -width),   # top right
		end_point + Vector2(0, width),    # bottom right
		laser_start_point.global_position + Vector2(0, width),  # bottom left
		]
