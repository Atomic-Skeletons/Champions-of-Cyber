class_name RollerShark extends StateMachine

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


@onready var normal_hurtbox: CollisionShape2D = %"Normal Hurtbox"
@onready var digging_hurtbox: CollisionShape2D = %"Digging Hurtbox"
@onready var digging_timer: Timer = %"Digging Timer"

var can_dig = true
var wall_dig_direction: int

@export var resurfacing_raycasts: Array[RayCast2D]
@export var wall_digging_raycast: RayCast2D

@onready var anim_sprite: AnimatedSprite2D = %"Anim Sprite"

var locked = false

func _ready() -> void:
	add_state("locked")
	add_state("skating")
	add_state("airborne")
	add_state("digging")
	add_state("wall_digging")
	add_state("stomp_attack")
	call_deferred("set_state", states.airborne)
	

func lock():
	locked = true

func _state_logic(delta):
	call_deferred("update_last_x_speed")
	if state == states.locked and is_hitstunned:
		move_and_slide()
	
	if state == states.skating:
		# if the player is moving in a direction they should keep their speed
		var direction := input.get_x_axis()
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
		var direction := input.get_x_axis()
		if direction:
			if moving_away(direction):
				velocity.x += direction * air_accelaration * delta
			if abs(velocity.x) < air_speed:
				velocity.x += direction * air_accelaration * delta
		velocity += get_gravity() * delta
		move_and_slide()
		update_facing_sprite()
	
	if state == states.digging:
		var direction := input.get_x_axis()
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
		if input.is_action_just_pressed("jump"):
			jump(jump_strength)
			return states.airborne
		if not is_on_floor():
			return states.airborne
		if input.is_action_just_pressed("special"):
			return states.stomp_attack
	
	if state == states.airborne:
		if is_on_floor():
			if input.is_action_pressed("jump") and _can_dig():
				return states.digging
			return states.skating
		if is_on_wall():
			if input.is_action_pressed("jump") and _can_dig():
				#get position of collision and put player there
				return states.wall_digging
	
	if state == states.digging:
		if not is_on_floor():
			return states.airborne
		
		if is_on_wall():
			return states.wall_digging
		# if there is something above the player then don't undig
		if input.is_action_just_released("jump"):
			resurfacing = true
		# if the player is trying to undig
		if resurfacing:
			# if neither raycasts are colliding, then undig
			if free_for_resurfacing():
				jump(digging_jump_strength)
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
		
		if input.is_action_just_released("jump"):
			resurfacing = true
		
		if resurfacing:
			if free_for_resurfacing():
				jumped.emit()
				velocity.x = -wall_dig_direction * abs(velocity.y)
				return states.airborne
	
	if state == states.stomp_attack:
		if not anim_player.is_playing():
			return states.skating
	
	return null

func _enter_state(new_state, old_state):
	if new_state == states.locked:
		anim_sprite.play("idle")
	
	if new_state == states.skating:
		anim_sprite.play("skating")
	
	if new_state == states.airborne:
		anim_sprite.play("idle")
	
	if new_state == states.digging:
		can_tag = false
		resurfacing = false
		digging_timer.start()
		normal_hurtbox.disabled = true
		digging_hurtbox.disabled = false
		anim_sprite.play("digging transition")
	
	if new_state == states.wall_digging:
		can_tag = false
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
	
	if new_state == states.stomp_attack:
		anim_player.play("stomp attack")
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _exit_state(old_state, new_state):
	if old_state == states.digging:
		can_tag = true
		can_dig = false
		normal_hurtbox.disabled = false
		digging_hurtbox.disabled = true
	
	if old_state == states.wall_digging:
		can_tag = true
		rotate(deg_to_rad(90 * wall_dig_direction))
		can_dig = false
		normal_hurtbox.disabled = false
		digging_hurtbox.disabled = true
	
	if old_state == states.airborne:
		can_dig = true


# Helper functions

func _can_dig():
	return can_dig

func jump(strength: float):
	jumped.emit()
	velocity.y = -strength

func moving_away(direction):
	if sign(velocity.x) != 0 and sign(direction) != sign(velocity.x):
		return true
	return false

func get_facing_direction() -> int:
	if not anim_sprite.flip_h:
		return 1
	else:
		return -1

@onready var fliproot: Node2D = $Fliproot
@onready var fliproot_init_scale_x: float = fliproot.scale.x
func update_facing_sprite():
	if velocity.x < 0:
		facing_dir = -1 # facing left
	elif velocity.x > 0:
		facing_dir = 1 # facing right
	
	if facing_dir == -1:
		fliproot.scale.x = -fliproot_init_scale_x
	elif facing_dir == 1:
		fliproot.scale.x = fliproot_init_scale_x

func set_fliproot(dir: int):
	if dir == -1:
		fliproot.scale.x = -fliproot_init_scale_x
	elif dir == 1:
		fliproot.scale.x = fliproot_init_scale_x

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


var hitstun_tween: Tween
var hitstop_tween: Tween
func _on_health_component_damaged(amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
	# create tween timers
	#anim_play("recoil")
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
