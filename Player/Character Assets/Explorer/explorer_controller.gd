class_name Explorer extends Character


signal jumped()
signal shot_laser_bullet()
signal laser_beam_started()
signal laser_beam_ended()
signal started_charging()
signal stopped_charging()


# components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_metter_component: AttackMetterComponent = $AttackMetterComponent


@export_group("Movement Variables")
@export var move_speed = 100.0
@export var jump_strength = 400.0
var prev_is_on_floor = false

@onready var laser_start_point: Marker2D = %"Laser Start Point"
@onready var laser_raycast: RayCast2D = %"Laser Raycast"
@onready var laser_line: Line2D = %"Laser Line"
@onready var laser_hitbox: Hitbox = %"Laser Hitbox"


@onready var attack_cooldown_timer: Timer = %"Attack Cooldown Timer"

@export_group("Laser Bullet")
@export var laser_bullet_meter_use: float = 20
@export var laser_bullet_scene: PackedScene
@export var laser_bullet_speed: float = 100

@onready var fliproot: Node2D = $Fliproot

@onready var anim_player: AnimationPlayer = %AnimationPlayer

@export_group("Laser Charge")
@export var laser_meter_use_per_sec: float = 20
@export var laser_charge_duration = .4
var laser_charge = 0
var mega_laser = false
@export var max_move_speed: float = 50
var jumping = false

func _ready() -> void:
	laser_hitbox.reparent(get_parent())
	laser_hitbox.global_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_hitstopped: return
	
	if is_hitstunned:
		anim_player.play("recoil")
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			air_movement = true
		
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor(): # if in the air
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
			# if the player is moving downwards
			if velocity.y > 10:
				jumping = false
			# if the player is moving upwards and holding the jumping button
			elif jumping:
				if not input.is_action_pressed("jump"):
					# add gravity again to double it
					velocity += get_gravity() * delta
			velocity += get_gravity() * delta
		# if the player is moving down
		if velocity.y > 0:
			anim_player.play("fall")
		# if the player is moving up
		elif velocity.y < 0:
			if will_hit_ceiling_in_frames(2):
				velocity.y *= 1./3
	# if the player is grounded
	else:
		jumping = false
		input.start_coyote_time()
		air_movement = true
	# Handle jump.
	if input.is_action_just_pressed("jump"):
		input.buffer_action("jump", .2)
	attempt_jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := input.get_x_axis()
	update_facing_direction(sign(direction))
	
	if direction:
		if is_on_floor() and anim_player.current_animation != "walk" and anim_player.current_animation != "jump":
			anim_player.play("walk")
		var speed = move_speed
		if mega_laser:
			speed /= 2
		#velocity.x += direction * ground_acceleration * delta
		velocity.x = direction * speed
	else:
		if is_on_floor() and not anim_player.current_animation in ["jump", "land"]:
			#anim_player.play("idle")
			anim_play("idle")
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	if is_on_ceiling():
		velocity.y = 0
		await get_tree().create_timer(.03, false, true).timeout
		velocity.y = 1
	
	velocity.y = min(velocity.y, terminal_velocity)
	
	move_and_slide()
	
	if input.is_action_pressed("attack"):
		anim_player.play("attack")
		if laser_charge == 0:
			started_charging.emit()
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
			stopped_charging.emit()
			shoot_laser_bullet()
			anim_player.stop()
		#anim_player.play("idle")
	if (not prev_is_on_floor) and is_on_floor() and not direction:
		anim_player.play("land")
	prev_is_on_floor = is_on_floor()

func anim_play(anim_name: String):
	anim_player.play(anim_name)

func update_facing_direction(dir: int):
	if dir != 0 and dir != facing_dir:
		facing_dir = sign(dir)
	fliproot.scale.x = sign(facing_dir)
	laser_hitbox.knockback_flipped = facing_dir == -1 if true else false

func will_hit_ceiling_in_frames(frames: int) -> bool:
	var total_movement = velocity * get_physics_process_delta_time() * frames
	var collision_detected = test_move(global_transform, total_movement)
	
	if collision_detected:
		var collision_info = KinematicCollision2D.new()
		if test_move(global_transform, total_movement, collision_info):
			if collision_info.get_normal().y > 0.7: # Adjust threshold based on your slopes
				return true
	return false

func attempt_jump():
	# check if the jump action is buffered
	if input.is_action_buffered("jump"):
		# if the character is on the floor
		if is_on_floor():
				jump()
		# if the character is not on the floor and they just pressed the jump button
		else:
			if input.in_coyote_time():
				jump()
			elif input.is_action_just_pressed("jump") and air_movement:
				air_movement = false
				jump()

func jump():
	anim_player.stop(true)
	anim_player.play("jump")
	jumping = true
	input.stop_coyote_time()
	input.use_buffered_action("jump")
	velocity.y = -jump_strength
	jumped.emit()

func in_attack_cooldown() -> bool:
	# if the timer is not going it means you're not in cooldown
	if attack_cooldown_timer.is_stopped():
		return false
	return true

func shoot_laser_bullet():
	if in_attack_cooldown():
		return
	else:
		attack_cooldown_timer.start()
	# checking for enough meter
	if attack_metter_component.can_use_metter(laser_bullet_meter_use):
		# use meter
		attack_metter_component.use_metter(laser_bullet_meter_use)
		# signal that shot happened
		shot_laser_bullet.emit()
		# spawn bullet
		var laser_bullet_object: RigidBody2D = laser_bullet_scene.instantiate()
		get_parent().add_child(laser_bullet_object)
		
		laser_bullet_object.global_position = laser_start_point.global_position
		laser_bullet_object.global_position.x += 15 * facing_dir
		laser_bullet_object.linear_velocity = Vector2(facing_dir*laser_bullet_speed, 0)

func update_animations():
	# in attack
	# on ground
	# direction
	# in knockback
	if is_hitstunned:
		anim_player.play("recoil")
	
	# attack checks
	elif mega_laser:
		anim_player.play("hold_attack")
	elif Input.is_action_pressed("attack") and not in_attack_cooldown():
		anim_player.play("attack")
	
	# If in air
	elif not is_on_floor():
		# rising up
		if velocity.y < 0:
			anim_player.play("jump")
		# falling down
		elif velocity.y > 0:
			anim_player.play("fall")
	# if on floor
	else:
		if velocity.x:
			pass
	# directional movement for walking
	# gravity animations


@onready var laser_pieces: Node2D = $"Fliproot/Laser Pieces"
@onready var start_marker: Marker2D = %"Start Marker"
@onready var end_marker: Marker2D = %"End Marker"
@onready var laser_collision_polygon: CollisionPolygon2D = %"Laser Collision Polygon"
@onready var laser_end: AnimatedSprite2D = %"Laser End"
@onready var mega_laser_shake: PhantomCameraNoiseEmitter2D = $"Mega Laser Shake"

func start_mega_laser():
	if in_attack_cooldown():
		return
	anim_player.play("hold_attack")
	stopped_charging.emit()
	laser_beam_started.emit()
	can_tag = false
	mega_laser = true
	laser_pieces.show()
	laser_line.show()
	laser_collision_polygon.disabled = false
	mega_laser_shake.emit()

func end_mega_laser():
	laser_beam_ended.emit()
	can_tag = true
	mega_laser = false
	laser_pieces.hide()
	laser_line.hide()
	laser_collision_polygon.set_deferred("disabled", true)
	mega_laser_shake.stop(true)
	laser_charge = 0
	
	attack_cooldown_timer.start()

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
	
	end_marker.position = fliproot.to_local(collision_point)
	
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


var hitstun_tween: Tween
var hitstop_tween: Tween
func _on_health_component_damaged(amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
	if mega_laser:
		end_mega_laser()
	# create tween timers
	if hitstun_duration:
		is_hitstunned = true
		hitstun_tween = Utilities.reset_tween(hitstun_tween, self)
		
		hitstun_tween.tween_interval(hitstun_duration)
		hitstun_tween.tween_callback(func(): is_hitstunned = false)
	
	if hitstop_duration:
		is_hitstopped = true
		hitstop_tween = Utilities.reset_tween(hitstop_tween, self)
		
		hitstop_tween.tween_interval(hitstop_duration)
		hitstop_tween.tween_callback(func(): is_hitstopped = false)


func _on_health_component_knockback(vector: Vector2) -> void:
	velocity = vector
