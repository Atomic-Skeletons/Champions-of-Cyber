class_name PlayerController extends CharacterBody2D


@onready var input_component: InputComponent = %InputComponent
@export var movement_component: MovementComponent
@export var attack_component: AttackComponent

var look_direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	
	input_component.update_inputs()
	if input_component.direction:
		look_direction = input_component.direction
	
	movement_component.move(self, input_component.direction, input_component.pressed_jump, delta)
	
	if input_component.pressed_attack:
		attack_component.attack(self, look_direction)
