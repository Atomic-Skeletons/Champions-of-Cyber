class_name ElectricController extends Character


@export var move_speed := 200
@export var jump_strength = -300.0

@export var dash_distance: float = 100
@export var dash_duration: float = 1
var in_dash = false
var dash_velocity: Vector2
@onready var dash_timer: Timer = %"Dash Timer"

@onready var fliproot: Node2D = %Fliproot

@onready var melee_hitbox: Hitbox = %"Melee Hitbox"
@export var melee_collision_shape: CollisionShape2D
@onready var attack_sprite: Sprite2D = $"Fliproot/Melee Hitbox/Attack Sprite"

var in_attack = false

func _ready() -> void:
	dash_timer.wait_time = dash_duration

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		air_movement = true
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := get_x_axis()
	if direction:
		if not in_attack:
			update_facing_direction(direction)
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	# Handle jump.
	if is_action_just_pressed("jump") and not in_dash:
		if is_on_floor():
			# jump
			velocity.y = jump_strength
		elif air_movement:
			# dash
			can_tag = false
			in_dash = true
			air_movement = false
			# this is where the dash happens
			var dir = direction
			if not dir:
				dir = facing_dir
			
			Utilities.disable_enemy_collision(self)
			dash_velocity = Vector2(facing_dir * dash_distance/dash_duration, 0)
			
			dash_timer.start()
	
	if in_dash:
		velocity = dash_velocity
	
	move_and_slide()
	
	if is_action_just_pressed("attack") and not in_dash:
		in_attack = true
		melee_collision_shape.disabled = false
		attack_sprite.show()
		await get_tree().create_timer(.1).timeout
		in_attack = false
		attack_sprite.hide()
		melee_collision_shape.disabled = true

func update_facing_direction(dir: int):
	facing_dir = sign(dir)
	fliproot.scale.x = sign(dir)
	melee_hitbox.knockback_flipped = false if dir == 1 else true

var hit_counter = 0
func _on_melee_hitbox_hit_body(body: Node2D) -> void:
	TimeController.control_time_scale(.01, .2, 0, 0, 1)
	hit_counter+=1


func _on_dash_timer_timeout() -> void:
	in_dash = false
	can_tag = true
	Utilities.enable_enemy_collision(self)
