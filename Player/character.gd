class_name Character extends CharacterBody2D

signal jumped()

@onready var input: PlayerInputHandler = get_input_handler_node()
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_metter_component: AttackMetterComponent = $AttackMetterComponent

var facing_dir: int = 1
var air_movement := true
var can_tag := true
var is_hitstopped := false
var is_hitstunned := false
@export var terminal_velocity: = 350

func character_move_and_slide():
	move_and_slide()
	# check for collision with spikes
	# and check for collisions with different terrain types like ice tiles
	# 2. Loop through all collisions that occurred during move_and_slide
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# 3. Check if the object we hit is a TileMapLayer
		if collider is TileMapLayer or collider is TileMap:
			
			# 4. Use the collision normal to "push" slightly into the tile.
			# This prevents getting an empty adjacent cell due to floating-point rounding.
			var collision_point = collision.get_position() - (collision.get_normal() * 4)
			
			# 5. Convert the global position into map coordinates
			var map_coords = collider.local_to_map(collider.to_local(collision_point))
			
			# 6. Fetch the tile's data
			# Note: If using the old TileMap node instead of TileMapLayer, 
			# you must pass the layer index as the first argument: collider.get_cell_tile_data(layer_index, map_coords)
			var tile_data: TileData = collider.get_cell_tile_data(map_coords)
			
			if tile_data:
				var spiked_damage_str := "spike damage"
				# 7. Extract your custom data or properties
				if tile_data.has_custom_data(spiked_damage_str):
					var spike_damage = tile_data.get_custom_data(spiked_damage_str)
					#var friction = tile_data.get_custom_data("friction")
					
					if spike_damage:
						var data = AttackData.new()
						data.damage = spike_damage
						var rad_angle = -collision_point.angle_to_point(global_position-Vector2(0, 20))
						var deg_angle = rad_to_deg(rad_angle)
						data.knockback_angle = deg_angle
						data.knockback_strength = 30
						data.hitstun_duration = .5
						health_component.damage(data)

func get_input_handler_node() -> PlayerInputHandler:
	for child in get_children():
		if child is PlayerInputHandler:
			return child
	return null
