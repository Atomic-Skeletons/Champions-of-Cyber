class_name ElectricController extends Character

signal jumped()
signal used_air_movement()
signal used_melee_attack()
signal used_charge_attack()

# components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_metter_component: AttackMetterComponent = $AttackMetterComponent


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

var in_attack = false

func _ready() -> void:
	dash_timer.wait_time = dash_duration

func _physics_process(delta: float) -> void:
	if is_hitstopped: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
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
	if input.is_action_just_pressed("jump") and not in_dash:
		if is_on_floor():
			# jump
			jumped.emit()
			velocity.y = -jump_strength
		elif air_movement:
			air_dash(direction)
			
			Utilities.disable_enemy_collision(self)
			dash_velocity = Vector2(facing_dir * dash_distance/dash_duration, 0)
			
			dash_timer.start()
	
	if in_dash:
		velocity = dash_velocity
	
	move_and_slide()
	
	if input.is_action_just_pressed("attack") and not in_dash:
		neutral_melee_attack()

func update_facing_direction(dir: int):
	if dir != 0 and dir != facing_dir:
		facing_dir = dir
	fliproot.scale.x = facing_dir
	melee_hitbox.knockback_flipped = false if facing_dir == 1 else true

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

func burst_attack():
	used_charge_attack.emit()

func air_dash(dir: float):
	used_air_movement.emit()
	
	can_tag = false
	in_dash = true
	air_movement = false
	# this is where the dash happens
	if not dir:
		dir = facing_dir

@onready var melee_attack_hitstop_timer: Timer = %"Melee Attack Hitstop Timer"
var hit_counter = 0
func _on_melee_hitbox_hit_body(body: Node2D) -> void:
	is_hitstopped = true
	melee_attack_hitstop_timer.start()
	hit_counter+=1


func _on_dash_timer_timeout() -> void:
	in_dash = false
	can_tag = true
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
