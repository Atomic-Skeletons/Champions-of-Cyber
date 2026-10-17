extends HBoxContainer

signal characters_selected(character_1_id: int, character_2_id: int)

@onready var input: UiInputHandlerTest = $UiInputHandler
@export_range(1,2) var player_id := 1
# State Machine
@onready var state_machine: LimboHSM = $LimboHSM

# States
@onready var char_1_selection_state : LimboState = $"LimboHSM/Character 1 Selection"
@onready var char_2_selection_state: LimboState = $"LimboHSM/Character 2 Selection"
@onready var done_state : LimboState = $LimboHSM/Done


@onready var character_1_portrait: Control = $"Character Portraits"
@onready var character_2_portrait: Control = $"Character Portraits2"

@export var character_grid: GridContainer

var unlocked_character_count: int
var grid_width: int

var character_1_id := 0:
	set(value):
		if value != character_1_id:
			update_portrait(character_1_portrait, value)
			update_grid(1, value)
		character_1_id = value
var character_2_id := -1:
	set(value):
		if value != character_2_id:
			if value == character_1_id:
				update_portrait(character_2_portrait, -1)
			else:
				update_portrait(character_2_portrait, value)
			update_grid(2, value)
		character_2_id = value

func _ready() -> void:
	# setup player input
	input.player_id = player_id
	input.update_input_data()
	
	# setup grid variables
	grid_width = character_grid.columns
	# for this one I need to get a count of each visible child
	# of the grid
	unlocked_character_count = 3
	
	# initialize portrait and grid
	update_portrait(character_1_portrait, character_1_id)
	update_portrait(character_2_portrait, character_2_id)
	update_grid(1, character_1_id)
	
	_initialize_state_machine()

func _initialize_state_machine():
	# Define state transitions
	# selecting character moving up
	state_machine.add_transition(char_1_selection_state, char_2_selection_state, "character_selected")
	state_machine.add_transition(char_2_selection_state, done_state, "character_selected")
	# unselecting character moving down
	state_machine.add_transition(char_2_selection_state, char_1_selection_state, "back")
	state_machine.add_transition(done_state, char_2_selection_state, "back")
	
	
	# Setup State Machine
	state_machine.initial_state = char_1_selection_state
	state_machine.initialize(self)
	state_machine.set_active(true)

func accepted_characters():
	characters_selected.emit(character_1_id, character_2_id)

func is_done() -> bool:
	return state_machine.get_active_state() == done_state

func update_portrait(portrait: Control, value):
	hide_all_portrait_children(portrait)
	if value != -1:
		portrait.get_child(value).show()

func hide_all_portrait_children(portrait: Control):
	for child in portrait.get_children():
		child.hide()

func deselect_character_2():
	character_2_id = -1

# grid functions
func update_grid(character_num: int, value: int):
	var indicator_path = "Player 1 Indicator"
	if character_num == 2:
		indicator_path = "Player 2 Indicator"
	
	for child in character_grid.get_children():
		child.get_node(indicator_path).hide()
	
	if value != -1:
		character_grid.get_child(value).get_node(indicator_path).show()


@warning_ignore("integer_division")
func move(character_num: int, dir: Vector2i) -> void:
	var width = grid_width
	var count = unlocked_character_count
	var index: int
	if character_num == 1:
		index = character_1_id
	elif character_num == 2:
		index = character_2_id
	
	
	var w := mini(width, count)  # grid can't be wider than the item count
	var row := index / w
	var col := index % w

	if dir.x != 0:
		# Length of this row (the last row may be partial)
		var row_len := mini(w, count - row * w)
		col = posmod(col + dir.x, row_len)
	elif dir.y != 0:
		# Height of this column: how many items sit in column `col`
		var col_height = (count - col + w - 1) / w
		row = posmod(row + dir.y, col_height)
	
	index = row * w + col
	
	if character_num == 1:
		character_1_id = index
	elif character_num == 2:
		character_2_id = index
