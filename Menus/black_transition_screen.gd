extends CanvasLayer

# need to know when 
signal animation_done
signal faded_in
signal faded_out


var screen_material: ShaderMaterial
@onready var transition_screen: ColorRect = %"Black Transition Screen"

var radius := 0.:
	set(value):
		radius = value
		set_radius(radius)
var inverted := true

var transition_tween: Tween

func _ready() -> void:
	show()
	screen_material = transition_screen.material
	transition_screen.hide()
	#fade_out()

func set_center_to_position(position: Vector2):
	var camera := get_viewport().get_camera_2d()
	var center = camera.get_canvas_transform() * position
	
	set_center(center)

func reset_center():
	set_center(Vector2(.5, .5))

func start_level_transition():
	transition_screen.show()
	transition_tween = Utilities.reset_tween(transition_tween, self)
	transition_tween.tween_property(self, "radius", 0, .5).from(2)
	await transition_tween.finished
	animation_done.emit()

func fade_in():
	pass

func fade_out():
	transition_screen.show()
	transition_tween = Utilities.reset_tween(transition_tween, self)
	radius = 0
	transition_tween.tween_interval(.3)
	transition_tween.tween_property(self, "radius", 1.5, .7)
	await transition_tween.finished
	faded_out.emit()
	transition_screen.hide()


func set_center(new_center: Vector2):
	screen_material.set_shader_parameter("center", new_center)

func set_radius(new_radius: float):
	transition_screen.material.set_shader_parameter("radius", new_radius)

func set_hole_mode():
	screen_material.set_shader_parameter("invert", true)

func set_ball_mode():
	screen_material.set_shader_parameter("invert", false)
