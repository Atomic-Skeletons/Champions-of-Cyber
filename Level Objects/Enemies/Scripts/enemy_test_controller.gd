class_name Enemy
extends CharacterBody2D

signal melee_attacked()
signal took_damage()

enum states {
	patroling,
	chasing,
	attacking
}
var state = states.patroling

@export var move_speed: float = 200

@onready var fliproot: Node2D = %Fliproot

var look_dir = 1:
	set(value):
		if value != 0:
			look_dir = sign(value)
			fliproot.scale.x = look_dir

@onready var player_holder := Global.get_player()
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var melee_attack_cooldown: Timer = $"Melee Attack Cooldown"

var in_knockback := false
var is_hitstopped := false
@export var knockback_multiplier = 1.
@onready var knockback_timer: Timer = Timer.new()
@onready var hitstop_timer: Timer = Timer.new()

@onready var sprite: Sprite2D = %Sprite2D
@onready var front_ground_cast: RayCast2D = $"Fliproot/Front Ground Cast"
@onready var front_wall_cast: RayCast2D = $"Fliproot/Front Wall Cast"

@export_category("Combat Variables")
@export var damage = 10
@export var attack_stop_distance = 10

func _ready() -> void:
	# adds timers and connects them to their respective functions
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
	
	match state:
		states.patroling:
			# move left and right and turn around when hitting a wall or if would fall off ledge
			var above_pit = front_ground_cast.is_colliding()
			var hitting_wall = front_wall_cast.is_colliding()
			if not above_pit or hitting_wall:
				look_dir *= -1
			velocity.x = look_dir * move_speed
		
		states.chasing:
			if is_on_floor() and player_holder:
				# Get the input direction and handle the movement/deceleration.
				# As good practice, you should replace UI actions with custom gameplay actions.
				var player_pos = player_holder.active_character.global_position
				var direction : int = sign(player_pos.x - global_position.x)
				if direction:
					look_dir = direction
					velocity.x = direction * move_speed
				else:
					velocity.x = move_toward(velocity.x, 0, move_speed)
				
				if not front_ground_cast.is_colliding():
					velocity.x = 0
				
				var distance_to_player = global_position.distance_to(player_pos)
				if distance_to_player < 50 :
					melee_attack()
		
		states.attacking:
			pass
	
	move_and_slide()

func melee_attack():
	if not melee_attack_cooldown.is_stopped():
		return
	melee_attacked.emit()
	animation_player.play("Melee Attack")
	state = states.attacking
	await animation_player.animation_finished
	melee_attack_cooldown.start()
	state = states.chasing

func _on_health_component_died() -> void:
	await get_tree().create_timer(.3).timeout
	queue_free()


func _on_health_component_knockback(vector: Vector2) -> void:
	velocity = vector * knockback_multiplier

func end_knockback():
	in_knockback = false

func end_hitstop():
	is_hitstopped = false

func _on_damaged(_amount: Variant, hitstun_duration: Variant, hitstop_duration: Variant) -> void:
	took_damage.emit()
	animation_player.call_deferred("play", "RESET")
	flash_hit(.3)
	if hitstun_duration:
		in_knockback = true
		knockback_timer.start(hitstun_duration)
	if hitstop_duration:
		is_hitstopped = true
		hitstop_timer.start(hitstop_duration)


func _on_saw_character(_character: Character) -> void:
	state = states.chasing


func flash_hit(duration: float = 0.15) -> void:
	var mat: ShaderMaterial = sprite.material as ShaderMaterial
	if not mat:
		return
	
	var tween := Utilities.reset_tween(null, self)
	mat.set_shader_parameter("flash_modifier", 3.0)
	tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, duration)
