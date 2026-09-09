class_name Player extends StateMachine


@export var ground_acceleration = 100
@export var ground_speed = 100
@export var ground_breaking_strength = 5
@export var max_velocity = 300
@export var jump_strength = 300

@export var digging_accelaration = 100
@export var digging_move_speed = 200
@export var digging_jump_strength = 400
var digging_stored_speed: float
var resurfacing = false
var wall_digging_starting_speed: float
var last_x_speed: float
var wall_digging_wait = .1
var wall_digging_timer = 0

@export var air_accelaration = 200
@export var air_speed = 75

@onready var normal_hurtbox: CollisionShape2D = $"Normal Hurtbox"
@onready var digging_hurtbox: CollisionShape2D = $"Digging Hurtbox"
@onready var digging_timer: Timer = $"Digging Timer"
var can_dig = true
var wall_dig_direction: int

@export var resurfacing_raycasts: Array[RayCast2D]
@export var wall_digging_raycast: RayCast2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var locked = false

func _ready() -> void:
	add_state("locked")
	add_state("skating")
	add_state("airborne")
	add_state("digging")
	add_state("wall_digging")
	call_deferred("set_state", states.airborne)
	
	#SignalBus.touched_win_flag.connect(lock)

func lock():
	locked = true

func _state_logic(delta):
	call_deferred("update_last_x_speed")
	if state == states.locked:
		move_and_slide()
	
	if state == states.skating:
		# if the player is moving in a direction they should keep their speed
		var direction := Input.get_axis("left", "right")
		if anim_sprite.animation != "skating":
			anim_sprite.play("skating")
		if direction:
			# if the player is moving away from the way they are moving
			if moving_away(direction):
				anim_sprite.play("breaking")
				#velocity.x += ground_breaking_strength * direction * ground_acceleration * delta
				velocity.x = move_toward(velocity.x, 0, ground_breaking_strength)
			elif abs(velocity.x) < ground_speed:
				anim_sprite.play("skating")
				velocity.x += direction * ground_acceleration * delta
				#velocity.x = direction * ground_speed
		else:
			anim_sprite.play("idle")
			velocity.x = move_toward(velocity.x, 0, .5)
			#velocity.x = 0
		
		move_and_slide()
		update_facing_sprite()
	
	if state == states.airborne:
		if velocity.y < 0:
			anim_sprite.play("rising")
		elif velocity.y > 0:
			anim_sprite.play("descending")
		var direction := Input.get_axis("left", "right")
		if direction:
			if moving_away(direction):
				velocity.x += direction * air_accelaration * delta
			if abs(velocity.x) < air_speed:
				velocity.x += direction * air_accelaration * delta
		velocity += get_gravity() * delta
		move_and_slide()
		update_facing_sprite()
	
	if state == states.digging:
		var direction := Input.get_axis("left", "right")
		if direction:
			if moving_away(direction):
				velocity.x *= -1
			if abs(velocity.x) < digging_move_speed:
				velocity.x += direction * digging_accelaration * delta
		else:
			velocity.x = move_toward(velocity.x, 0, .5)
	
		move_and_slide()
		update_facing_sprite()
	
	if state == states.wall_digging:
		velocity.x = wall_dig_direction * 100
		if abs(velocity.y) < digging_move_speed:
			velocity.y -= digging_accelaration * delta
		
		move_and_slide()
		update_facing_sprite()

func _get_transition(delta):
	if locked and state != states.locked and state != states.airborne:
		return states.locked
	if state == states.skating:
		if Input.is_action_just_pressed("jump"):
			if Input.is_action_pressed("down") and standing_on_one_way_platform():
				global_position.y += 1
				return states.airborne
			velocity.y = -jump_strength
			return states.airborne
		if not is_on_floor():
			return states.airborne
	
	if state == states.airborne:
		if is_on_floor():
			if Input.is_action_pressed("jump") and can_dig:
				return states.digging
			return states.skating
		if is_on_wall():
			if Input.is_action_pressed("jump") and can_dig:
				#get position of collision and put player there
				return states.wall_digging
	
	if state == states.digging:
		if not is_on_floor():
			return states.airborne
		
		if is_on_wall():
			return states.wall_digging
		# if there is something above the player then don't undig
		if Input.is_action_just_released("jump"):
			resurfacing = true
		# if the player is trying to undig
		if resurfacing:
			# if neither raycasts are colliding, then undig
			if free_for_resurfacing():
				if not Input.is_action_pressed("down"):
					velocity.y = -digging_jump_strength
				#velocity.x = sign(velocity.x) * digging_stored_speed
				return states.airborne
	
	if state == states.wall_digging:
		# in this state the player will be moving up at all times
		# then when they let go of the jump button they'll jump off
		if wall_digging_timer >= wall_digging_wait:
			if not wall_digging_raycast.is_colliding():
				return states.airborne
		else:
			wall_digging_timer += delta
		
		if Input.is_action_just_released("jump"):
			resurfacing = true
		
		if resurfacing:
			if free_for_resurfacing():
				velocity.x = -wall_dig_direction * abs(velocity.y)
				return states.airborne
	
	return null

func _enter_state(new_state, old_state):
	if new_state == states.locked:
		anim_sprite.play("idle")
	
	if new_state == states.skating:
		anim_sprite.play("skating")
	
	if new_state == states.airborne:
		anim_sprite.play("idle")
	
	if new_state == states.digging:
		resurfacing = false
		digging_timer.start()
		normal_hurtbox.disabled = true
		digging_hurtbox.disabled = false
		anim_sprite.play("digging transition")
	
	if new_state == states.wall_digging:
		# translate horizontal move speed into vertical speed
		velocity.y = -abs(last_x_speed)
		wall_dig_direction = sign(last_x_speed)
		if not wall_dig_direction:
			wall_dig_direction = get_facing_direction()
		rotate(deg_to_rad(-90 * wall_dig_direction))
		wall_digging_timer = 0
		resurfacing = false
		digging_timer.start()
		normal_hurtbox.disabled = true
		digging_hurtbox.disabled = false
		anim_sprite.play("digging transition")
	

func _exit_state(old_state, new_state):
	if old_state == states.digging:
		can_dig = false
		normal_hurtbox.disabled = false
		digging_hurtbox.disabled = true
	
	if old_state == states.wall_digging:
		rotate(deg_to_rad(90 * wall_dig_direction))
		can_dig = false
		normal_hurtbox.disabled = false
		digging_hurtbox.disabled = true
	
	if old_state == states.airborne:
		can_dig = true


# Helper functions

func moving_away(direction):
	if sign(velocity.x) != 0 and sign(direction) != sign(velocity.x):
		return true
	return false

func get_facing_direction() -> int:
	if not anim_sprite.flip_h:
		return 1
	else:
		return -1

func update_facing_sprite():
	if velocity.x < 0:
		anim_sprite.flip_h = true
	elif velocity.x > 0:
		anim_sprite.flip_h = false

func standing_on_one_way_platform():
	var on_one_way_platform = false
	if is_on_floor():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			# Check if the collision normal points upwards (meaning floor is beneath)
			if collision.get_normal().dot(Vector2.UP) > 0.5:
				# If it's a TileMapLayer or a collision object, you can check 
				# if the specific local shape index is a one-way collision:
				var collider = collision.get_collider()
				#var shape_idx = collision.get_local_shape()
				
				# For a standard CollisionObject2D (StaticBody2D, etc.)
				if collider is CollisionObject2D:
					if collider.is_shape_owner_one_way_collision_enabled(0):
						on_one_way_platform = true
	return on_one_way_platform

func free_for_resurfacing() -> bool:
	var raycast_colliding = false
	for raycast: RayCast2D in resurfacing_raycasts:
		if raycast.is_colliding():
			raycast_colliding = true
	return not raycast_colliding

func update_last_x_speed():
	last_x_speed = velocity.x
	if state == states.wall_digging:
		last_x_speed = velocity.y

func _on_digging_timer_timeout() -> void:
	if state == states.digging or state == states.wall_digging:
		resurfacing = true
