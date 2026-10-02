class_name Explorer extends Character

# components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_metter_component: AttackMetterComponent = $AttackMetterComponent


@export_group("Movement Variables")
@export var move_speed = 100.0
@export var jump_strength = 300.0


@onready var laser_start_point: Marker2D = %"Laser Start Point"
@onready var laser_raycast: RayCast2D = %"Laser Raycast"
@onready var laser_line: Line2D = %"Laser Line"
@onready var laser_hitbox: Hitbox = %"Laser Hitbox"

@export_group("Laser Bullet")
@export var laser_bullet_meter_use: float = 20
@export var laser_bullet_scene: PackedScene
@export var laser_bullet_speed: float = 100

@onready var fliproot: Node2D = $Fliproot

@onready var anim_sprite: AnimatedSprite2D = $Fliproot/AnimatedSprite2D

@export_group("Laser Charge")
@export var laser_meter_use_per_sec: float = 20
@export var laser_charge_duration = .4
var laser_charge = 0
var mega_laser = false
@export var max_move_speed: float = 50


func _ready() -> void:
	laser_hitbox.reparent(get_parent())
	laser_hitbox.global_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if input.is_action_pressed("attack"):
			# while the player is holding the mega laser button
			# they slow down their movement
			velocity += get_gravity() * delta / 10
			if velocity.y < 0:
				velocity.y = lerp(velocity.y, 0.0, .2)
			elif velocity.y > 0:
				if velocity.y > max_move_speed:
					velocity.y = lerp(velocity.y, max_move_speed, .2)
		else:
			velocity += get_gravity() * delta
	else:
		air_movement = true
	# Handle jump.
	if input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_strength
		elif air_movement:
			air_movement = false
			velocity.y = -jump_strength
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := input.get_x_axis()
	update_facing_direction(sign(direction))
	
	if direction:
		var speed = move_speed
		if mega_laser:
			speed /= 2
		#velocity.x += direction * ground_acceleration * delta
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	move_and_slide()
	
	if input.is_action_pressed("attack"):
		anim_sprite.play("attack")
		laser_charge += delta
		if not mega_laser and laser_charge >= laser_charge_duration:
			start_mega_laser()
		if mega_laser:
			update_mega_laser(delta)
	
	if input.is_action_just_released("attack"):
		laser_charge = 0
		if mega_laser:
			end_mega_laser()
		else:
			shoot_laser_bullet()
			anim_sprite.stop()
		anim_sprite.play("idle")
	
	global_position = global_position.round()

func update_facing_direction(dir: int):
	if dir != 0 and dir != facing_dir:
		facing_dir = sign(dir)
	fliproot.scale.x = sign(facing_dir)
	laser_hitbox.knockback_flipped = facing_dir == -1 if true else false

@onready var laser_bullet: RandomPitchPlayer = %LaserBullet

func shoot_laser_bullet():
	var metter_used = 20
	if attack_metter_component.can_use_metter(metter_used):
		attack_metter_component.use_metter(20)
		laser_bullet.play_random_pitch()
		var laser_bullet_object: RigidBody2D = laser_bullet_scene.instantiate()
		get_parent().add_child(laser_bullet_object)
		
		laser_bullet_object.global_position = laser_start_point.global_position
		laser_bullet_object.global_position.x += 15 * facing_dir
		laser_bullet_object.linear_velocity = Vector2(facing_dir*laser_bullet_speed, 0)


@onready var laser_pieces: Node2D = $"Fliproot/Laser Pieces"
@onready var start_marker: Marker2D = %"Start Marker"
@onready var end_marker: Marker2D = %"End Marker"
@onready var laser_collision_polygon: CollisionPolygon2D = %"Laser Collision Polygon"
@onready var laser_end: Sprite2D = %"Laser End"
@onready var mega_laser_shake: PhantomCameraNoiseEmitter2D = $"Mega Laser Shake"

func start_mega_laser():
	can_tag = false
	mega_laser = true
	laser_pieces.show()
	laser_line.show()
	laser_collision_polygon.disabled = false
	mega_laser_shake.emit()

func end_mega_laser():
	can_tag = true
	mega_laser = false
	laser_pieces.hide()
	laser_line.hide()
	laser_collision_polygon.disabled = true
	mega_laser_shake.stop(true)
	laser_charge = 0

func update_mega_laser(delta: float):
	var mega_laser_meter_use = laser_meter_use_per_sec * delta
	# if they don't have enough meter, then end the mega laser
	if not attack_metter_component.can_use_metter(mega_laser_meter_use):
		end_mega_laser()
		return
	
	attack_metter_component.use_metter(mega_laser_meter_use)
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
