class_name ExplorerTest extends Character


signal shot_laser_bullet()
signal laser_beam_started()
signal laser_beam_ended()
signal started_charging()
signal stopped_charging()

@onready var hsm: LimboHSM = $"Character States"

## States
@onready var grounded: LimboState = $"Character States/Grounded"
@onready var aerial: LimboState = $"Character States/Aerial"
@onready var jump: LimboState = $"Character States/Jump"
@onready var fall: LimboState = $"Character States/Fall"
@onready var charge_laser: LimboState = $"Character States/Charge Laser"
@onready var laser_bullet_attack: LimboState = $"Character States/Laser Bullet Attack"
@onready var hitstun: LimboState = $"Character States/Hitstun"
@onready var knockback: LimboState = $"Character States/Knockback"


@onready var fliproot: Node2D = $Fliproot
@onready var anim_player: AnimationPlayer = %AnimationPlayer

var move_speed = 100

func _ready() -> void:
	_initialize_state_machine()

func _initialize_state_machine():
	# Define state transitions
	# entering hitstun and knockback transitions
	hsm.add_transition(hsm.ANYSTATE, hitstun, "hitstun")
	hsm.add_transition(hsm.ANYSTATE, knockback, "knockback")
	hsm.add_transition(knockback, grounded, "recover")
	
	# movement transitions
	hsm.add_transition(grounded, fall, "falling")
	hsm.add_transition(jump, fall, "falling")
	hsm.add_transition(fall, grounded, "landed")
	hsm.add_transition(jump, grounded, "landed")
	hsm.add_transition(grounded, jump, "jumped")
	hsm.add_transition(grounded, charge_laser, "start_charge")
	
	
	# Setup State Machine
	hsm.initial_state = grounded
	hsm.initialize(self)
	hsm.set_active(true)

func x_move(direction: int):
	if direction:
		var speed = move_speed
		
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

func update_facing_direction(dir: int):
	if dir != 0 and dir != facing_dir:
		facing_dir = sign(dir)
	fliproot.scale.x = sign(facing_dir)
	#laser_hitbox.knockback_flipped = facing_dir == -1 if true else false


func _on_health_component_knockback(vector: Vector2) -> void:
	hsm.dispatch("knockback", vector)


func _on_health_component_damaged(_amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
	pass # Replace with function body.


func _on_health_component_hit(_amount: Variant, knockback_vector: Variant, knockback_duration: Variant, hitstop_duration: Variant) -> void:
	if hitstop_duration:
		hsm.dispatch("hitstun", [
			hitstop_duration,
			[knockback_vector, knockback_duration]
		])
	
