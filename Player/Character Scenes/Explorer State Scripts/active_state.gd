extends LimboState


@onready var character: ExplorerTest = agent

@onready var state_machine: LimboHSM = $"Explorer States"

## States
@onready var aerial: LimboState = $"Explorer States/Aerial"
@onready var grounded: LimboState = $"Explorer States/Grounded"
@onready var attack: LimboState = $"Explorer States/Attack"
@onready var mega_laser: LimboState = $"Explorer States/Mega Laser"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _update(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
