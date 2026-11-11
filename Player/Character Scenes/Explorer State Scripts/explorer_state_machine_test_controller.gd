class_name ExplorerTest extends LimboHSM


signal shot_laser_bullet()
signal laser_beam_started()
signal laser_beam_ended()
signal started_charging()
signal stopped_charging()


## States
@onready var grounded_state: LimboState = $Grounded
@onready var aerial_state: LimboState = $Aerial
@onready var charge_laser_state: LimboState = $"Charge Laser"
@onready var laser_bullet_attack_state: LimboState = $"Laser Bullet Attack"
@onready var hitstun_state: LimboState = $Hitstun
@onready var knockback_state: LimboState = $Knockback


func _ready() -> void:
	_initialize_state_machine()

func _initialize_state_machine():
	# Define state transitions
	# entering hitstun and knockback transitions
	add_transition(
		ANYSTATE, 
		hitstun_state, 
		"hitstun")
	add_transition(
		ANYSTATE, 
		knockback_state, 
		"knockback")
	
	# movement transitions
	add_transition(
		grounded_state,
		charge_laser_state,
		"start_charge"
	)
	
	# Setup State Machine
	initial_state = grounded_state
	initialize(self)
	set_active(true)


func _on_health_component_knockback(vector: Vector2) -> void:
	dispatch("hitstun")
