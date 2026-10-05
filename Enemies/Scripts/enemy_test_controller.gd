extends CharacterBody2D

@export var move_speed: float = 200
@onready var player_holder := Global.get_player()
@onready var health_component: HealthComponent = $HealthComponent

var in_knockback := false
var is_hitstopped := false
@onready var knockback_timer: Timer = Timer.new()
@onready var hitstop_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(knockback_timer)
	knockback_timer.one_shot = true
	knockback_timer.timeout.connect(end_knockback)
	
	add_child(hitstop_timer)
	hitstop_timer.one_shot = true
	hitstop_timer.timeout.connect(end_hitstop)
	

func _physics_process(delta: float) -> void:
	if is_hitstopped: return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if in_knockback:
		move_and_slide()
		return

	if is_on_floor() and player_holder:
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

func end_knockback():
	in_knockback = false

func end_hitstop():
	is_hitstopped = false

func _on_damaged(_amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
	if hitstun_duration:
		in_knockback = true
		knockback_timer.start(hitstun_duration)
	if hitstop_duration:
		is_hitstopped = true
		hitstop_timer.start(hitstop_duration)
