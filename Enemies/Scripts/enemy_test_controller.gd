extends CharacterBody2D

@export var move_speed: float = 200
@onready var player_holder := Global.get_player()
@onready var health_component: HealthComponent = $HealthComponent

var in_knockback := false
@onready var knockback_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(knockback_timer)
	knockback_timer.one_shot = true
	knockback_timer.timeout.connect(end_knockback)
	knockback_timer.wait_time = .3

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if in_knockback:
		move_and_slide()
		return

	if is_on_floor():
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var player_pos = player_holder.active_character.global_position.x
		var direction : int = sign(player_pos - global_position.x)
		if direction:
			velocity.x = direction * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()


func _on_health_component_died() -> void:
	await get_tree().create_timer(.3).timeout
	queue_free()


func _on_health_component_knockback(vector: Vector2) -> void:
	velocity = vector
	in_knockback = true
	knockback_timer.start()

func end_knockback():
	in_knockback = false
