extends VBoxContainer


@export_range(1,2) var player_id = 1

@export var health_bar_1: Range
@export var metter_bar_1: Range
var health_controller_1: HealthComponent
var metter_controller_1: AttackMetterComponent


@export var health_bar_2: Range
@export var metter_bar_2: Range
var health_controller_2: HealthComponent
var metter_controller_2: AttackMetterComponent

func _ready() -> void:
	await get_tree().process_frame
	set_player_controllers()

func _process(delta: float) -> void:
	health_bar_1.value = health_controller_1.current_hp
	metter_bar_1.value = metter_controller_1.value
	
	health_bar_2.value = health_controller_2.current_hp
	metter_bar_2.value = metter_controller_2.value
	

func set_player_controllers():
	for holder: PlayerCharacterHolder in get_tree().get_nodes_in_group("Player"):
		if holder.player_id == player_id:
			# get the health and metter controllers of the first character
			health_controller_1 = holder.character_1.health_component
			metter_controller_1 = holder.character_1.attack_metter_component
			health_bar_1.max_value = health_controller_1.max_hp
			metter_bar_1.max_value = metter_controller_1.max_metter
			
			health_controller_2 = holder.character_2.health_component
			metter_controller_2 = holder.character_2.attack_metter_component
			health_bar_2.max_value = health_controller_2.max_hp
			metter_bar_2.max_value = metter_controller_2.max_metter
