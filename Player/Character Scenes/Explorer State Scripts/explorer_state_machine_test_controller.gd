class_name ExplorerTest extends Character


signal jumped()
signal shot_laser_bullet()
signal laser_beam_started()
signal laser_beam_ended()
signal started_charging()
signal stopped_charging()

@onready var state_machine: LimboHSM = $"Character States"

## States
@onready var active_state: LimboState = $"Character States/Active"
@onready var hitstun_state: LimboState = $"Character States/Hitstun"
@onready var knockback_state: LimboState = $"Character States/Knockback"
@onready var locked_state: LimboState = $"Character States/Locked"
@onready var tagged_out_state: LimboState = $"Character States/Tagged Out"


func _ready() -> void:
	_initialize_state_machine()

func _initialize_state_machine():
	# Define state transitions
	# entering hitstun and knockback transitions
	state_machine.add_transition(
		active_state, 
		hitstun_state, 
		"hitstun")
	state_machine.add_transition(
		state_machine.ANYSTATE, 
		knockback_state, 
		"knockback")
	
	# go back to active after knockback is finished
	state_machine.add_transition(
		knockback_state,
		active_state,
		knockback_state.EVENT_FINISHED
	)
	
	# locking the player from any state
	state_machine.add_transition(
		state_machine, 
		locked_state, 
		"lock player")
	
	# Tagging out from any state
	state_machine.add_transition(
		state_machine.ANYSTATE, 
		tagged_out_state, 
		"tag out")
	state_machine.add_transition(
		tagged_out_state,
		active_state,
		"tag in"
	)
	
	
	# Setup State Machine
	state_machine.initial_state = active_state
	state_machine.initialize(self)
	state_machine.set_active(true)
