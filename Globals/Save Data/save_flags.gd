class_name SaveFlags
extends Resource


## Input source save data
var player_1_input_info: Dictionary = {
	input_source = 0,
	player_index = 1,
	joypad_device = 0
	}
var player_2_input_info: Dictionary = {
	input_source = 0,
	player_index = 2,
	joypad_device = 0
	}

#region Character Unlock Checks

var unlocked_explorer = true
var unlocked_electric_boogaloo = true
var unlocked_shark_man = true
var unlocked_blockbert = true

#endregion

#region Level Checks

## Forest Levels
# Columns
var beat_columns = false
var columns_humans_collected = {
	first_guy = false,
	second_guy = false
}
# Trees
var beat_trees = false
var trees_humans_collected = {
	first_guy = false
}
# Fields
var beat_fields = false
var field_humans_collected = {
	first_guy = false
}
# Tree Hollow
var beat_treehollow = false
var treehollow_humans_collected = {
	first_guy = false
}

## Cave Levels
# Tunnel
var beat_tunnel = false
var tunnel_humans_collected = {
	first_guy = false
}
# Plummet
var beat_plummet = false
var plummet_humans_collected = {
	first_guy = false
}
# Crushing
var beat_crushing = false
var crushing_humans_collected = {
	first_guy = false
}

#endregion

## World checks
var killed_the_boss = false
