extends Node2D

#disable enemy timer in the enemy scene so it doesnt move until we want it to
#think about increasing max enemies over time
#randomize spawn position
#set max enemies
#get current spawn count
#check tilemap  for spawnable locations

#reference to our empty node2d container for spawned enemies
@onready var spawned_enemies = $SpawnedEnemies
@onready var tilemap = get_tree().root.get_node("Main/Terrain")

#enemy vars
@export var max_enemies = 20
var enemy_count = 0
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_enemy():
	var attempts = 0
	var max_attempts = 100
	var spawned = false
	
	while not spawned and attempts < max_attempts:
		#random number for position in x and y
		var random_position = Vector2(rng.randi() % tilemap.get_used_rect().size.x,  rng.randi() % tilemap.get_used_rect().size.y)
		if is_valid_spawn_location(Global.GRASS_LAYER, random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.position = tilemap.map_to_local(random_position) + Vector2(tilemap.tile_size.x, tilemap.tile_size.y)/2
			spawned_enemies.add_child(enemy)
			spawned = true
		else:
			attempts += 1
	if attempts >= max_attempts:
		pass

#add player position as a non valid spawn point
#how to spawn from a specific location with a direction
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	#first check if it is an invalid tile
	if tilemap.get_cell_source_id(Global.WATER_LAYER, cell_coords) != -1 ||tilemap.get_cell_source_id(Global.BUILDING_LAYER, cell_coords) != -1 || tilemap.get_cell_source_id(Global.FOLIAGE_LAYER, cell_coords) != -1:
		return false
	#second check if valid tile
	if tilemap.get_cell_source_id(Global.GRASS_LAYER, cell_coords) != -1:
		return true