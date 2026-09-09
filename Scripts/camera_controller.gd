extends Camera2D

@onready var player: Player = Global.get_player()
@export var x_max_follow_distance = 200
var follow_variance: float = 0
@export var follow_damping = .2
@export var x_damping = .15
@export var y_damping = .15

#@onready var y_offset = global_position.y - player.global_position.y

var following = true

func _ready() -> void:
	global_position = player.global_position
	#SignalBus.touched_win_flag.connect(stop_following)


func _process(delta: float) -> void:
	if not following: return
	# as long as the player is moving the camera will progressively
	# go more forward until the max
	
	# based on the player's speed the camera will be infront of them
	var target_x: float = player.global_position.x
	var follow_ahead: float
	
	var player_x_velocity = 50 #lerp(0, x_max_follow_distance, player.velocity.x)
	
	follow_ahead = clamp(player_x_velocity, -x_max_follow_distance, x_max_follow_distance)
	#follow_ahead = x_max_follow_distance
	follow_variance = lerp(follow_variance, follow_ahead, follow_damping)
	target_x = player.global_position.x + follow_variance
	
	global_position.x = lerp(global_position.x, target_x, x_damping)
	
	
	global_position.y = lerp(global_position.y, player.global_position.y, y_damping)

func stop_following():
	following = false
