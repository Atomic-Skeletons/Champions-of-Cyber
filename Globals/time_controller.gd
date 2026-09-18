extends Node

var time_scale: float
var target_time_scale: float
var active_time_change := false
var current_priority := -1000
var time_scale_difference: float

var time_duration: float
var duration_timer: float

var fade_in_duration: float
var fade_out_duration: float

var fade_in = false
var fade_out = false

func _ready() -> void:
	pass

func control_time_scale(target_time_scale: float, duration: float, fade_in_duration: float, fade_out_duration: float,  priority: int):
	if priority >= current_priority:
		Engine.time_scale = 1
		active_time_change = true
		fade_in = true
		fade_out = false
		self.target_time_scale = target_time_scale
		time_scale_difference = 1 - target_time_scale
		self.fade_in_duration = fade_in_duration
		self.fade_out_duration = fade_out_duration
		time_duration = duration
		duration_timer = 0

func _process(delta: float) -> void:
	if active_time_change:
		if fade_in:
			time_scale = move_toward(
				time_scale, target_time_scale, 
				time_scale_difference * delta / fade_in_duration / Engine.time_scale)
			if time_scale == target_time_scale:
				fade_in = false
		elif fade_out:
			time_scale = move_toward(
				time_scale, 1, 
				time_scale_difference * delta / fade_out_duration / Engine.time_scale)
			if time_scale == 1:
				fade_out = false
		else:
			if duration_timer >= time_duration:
				fade_out = true
				current_priority = -1000
			duration_timer += delta / Engine.time_scale
		Engine.time_scale = time_scale
