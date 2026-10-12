class_name Level1Test
extends Level

@export var default_spawn: StringName = &"Start"

@onready var player1: PlayerCharacterHolder = get_tree().get_first_node_in_group("Player")
@onready var player2: PlayerCharacterHolder = get_tree().get_nodes_in_group("Player")[1] if get_tree().get_nodes_in_group("Player").size() > 1 else null

func _ready() -> void:
	var spawn_name :StringName = LevelManager.next_spawn if LevelManager.next_spawn != &"" else default_spawn
	var spawn := get_node_or_null("SpawnPoints/%s" % spawn_name)
	if spawn:
		player1.active_character.global_position = spawn.global_position
		if player2:
			player2.active_character.global_position = spawn.global_position
	else:
		push_warning("Spawn point '%s' not found in %s" % [spawn_name, name])
	LevelManager.next_spawn = &""
