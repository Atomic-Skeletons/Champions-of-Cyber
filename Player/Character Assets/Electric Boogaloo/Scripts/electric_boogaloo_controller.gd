class_name ElectricController extends Character

signal jumped()
signal used_air_movement()
signal used_melee_attack()
signal used_charge_attack()
signal used_downwarde_kick()

# components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_metter_component: AttackMetterComponent = $AttackMetterComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var move_speed := 200
@export var jump_strength = 300.0

@export var dash_distance: float = 100
@export var dash_duration: float = 1
var in_dash = false
var dash_velocity: Vector2
@onready var dash_timer: Timer = %"Dash Timer"

@onready var fliproot: Node2D = %Fliproot

@export var melee_meter_use: float = 30
@onready var melee_hitbox: Hitbox = %"Melee Hitbox"
@export var melee_collision_shape: CollisionShape2D
@onready var attack_sprite: Sprite2D = $"Fliproot/Melee Hitbox/Attack Sprite"

@export var downward_kick_meter_use: float = 30
@onready var burst_attack_timer: Timer = %"Burst Attack Timer"
@export var burst_attack_meter_use: float = 50

var in_attack = false
var just_attacked = false

func _ready() -> void:
	dash_timer.wait_time = dash_duration

func _physics_process(delta: float) -> void:
	if is_hitstopped: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		input.start_coyote_time()
		air_movement = true
	
	if is_hitstunned:
		move_and_slide()
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := input.get_x_axis()
	if not in_attack:
		update_facing_direction(sign(direction))
	
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	# Handle jump.
	if input.is_action_just_pressed("jump"):
		input.buffer_action("jump", .2)
	attempt_jump()
	
	
	if in_dash:
		velocity = dash_velocity
	
	if in_burst:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	if input.is_action_just_released("attack") and not just_attacked and not in_dash:
		if input.is_action_pressed("down"):
			downward_kick_attack()
		else:
			neutral_melee_attack()
	
	if input.is_action_just_pressed("attack"):
		burst_attack_timer.start()
	if input.is_action_pressed("attack") and not in_attack:
		burst_attack_timer.paused = false
	else:
		burst_attack_timer.paused = true
	if input.is_action_just_released("attack"):
		just_attacked = false
		burst_attack_timer.stop()
	

func update_facing_direction(dir: int):
	if dir != 0 and dir != facing_dir:
		facing_dir = dir
	fliproot.scale.x = facing_dir
	melee_hitbox.knockback_flipped = false if facing_dir == 1 else true

func attempt_jump():
	# check if the jump action is buffered
	if input.is_action_buffered("jump"):
		# if the character is on the floor
		if is_on_floor():
				jump()
		# if the character is not on the floor and they just pressed the jump button
		else:
			# this is where I check for coyote time
			if input.in_coyote_time():
				input.stop_coyote_time()
				jump()
			elif input.is_action_just_pressed("jump") and air_movement:
				air_movement = false
				start_air_dash()

func jump():
	input.stop_coyote_time()
	input.use_buffered_action("jump")
	velocity.y = -jump_strength
	jumped.emit()


#region Attack Methods
func neutral_melee_attack():
	if attack_metter_component.can_use_metter(melee_meter_use):
		attack_metter_component.use_metter(melee_meter_use)
		used_melee_attack.emit()
		in_attack = true
		melee_collision_shape.disabled = false
		attack_sprite.show()
		await get_tree().create_timer(.1).timeout
		in_attack = false
		attack_sprite.hide()
		melee_collision_shape.disabled = true

func downward_kick_attack():
	if attack_metter_component.can_use_metter(downward_kick_meter_use):
		attack_metter_component.use_metter(downward_kick_meter_use)
		used_downwarde_kick.emit()
		in_attack = true
		animation_player.play("Downward Kick")
		velocity.y = 40
		await animation_player.animation_finished
		in_attack = false
		

var in_burst = false
func burst_attack():
	if attack_metter_component.can_use_metter(burst_attack_meter_use):
		attack_metter_component.use_metter(burst_attack_meter_use)
		used_charge_attack.emit()
		in_attack = true
		in_burst = true
		just_attacked = true
		animation_player.play("Burst Attack")
		await animation_player.animation_finished
		in_attack = false
		in_burst = false

func start_air_dash():
	used_air_movement.emit()
	
	# disable collisions so the player passes through enemies but not platforms
	Utilities.disable_enemy_collision(self)
	
	dash_velocity = Vector2(facing_dir * dash_distance/dash_duration, 0)
	
	dash_timer.start()
	
	animation_player.play("Enter Dash Stance")
	can_tag = false
	in_dash = true
	air_movement = false

@onready var melee_attack_hitstop_timer: Timer = %"Melee Attack Hitstop Timer"
var hit_counter = 0
func _on_melee_hitbox_hit_body(body: Node2D) -> void:
	is_hitstopped = true
	melee_attack_hitstop_timer.start()
	hit_counter+=1


func _on_dash_timer_timeout() -> void:
	in_dash = false
	can_tag = true
	animation_player.play("RESET")
	Utilities.enable_enemy_collision(self)


func _on_melee_attack_hitstop_timer_timeout() -> void:
	is_hitstopped = false


var hitstun_tween: Tween
var hitstop_tween: Tween
func _on_health_component_damaged(amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
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


func _on_downward_kick_hitbox_hit_body(body: Node2D) -> void:
	air_movement = true
	jump()


func _on_burst_attack_timer_timeout() -> void:
	burst_attack()
