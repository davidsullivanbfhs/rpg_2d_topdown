extends Node2D

#disable enemy timer in the enemy scene so it doesnt move until we want it to
#think about increasing max enemies over time
#randomize spawn position
#set max enemies
#get current spawn count
#check tilemap  for spawnable locations

#reference to our empty node2d container for spawned enemies
@onready var spawned_enemies = $SpawnedEnemies
@onready var tilemap = $"../Terrain"

#### for david only ###
@onready var tilemapItems = $"../Items"
@onready var tilemapWater = $"../Water"

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
		print("tring to spawn an enemy")
		#random number for position in x and y
		var random_position = Vector2(rng.randi() % tilemap.get_used_rect().size.x,  rng.randi() % tilemap.get_used_rect().size.y)
		### this check is just for me because i am using tilemaplayers
		if tilemap.is_a("TileMap"):
			if is_valid_spawn_location(Global.GRASS_LAYER, random_position):
				var enemy = Global.enemy_scene.instantiate()
				enemy.position = tilemap.map_to_local(random_position) + Vector2(tilemap.tile_size.x, tilemap.tile_size.y)/2
				spawned_enemies.add_child(enemy)
				spawned = true
			else:
				attempts += 1
		else:
			if is_valid_spawn_location(Global.GRASS_LAYER, random_position):
				var enemy = Global.enemy_scene.instantiate()
				enemy.position = tilemap.map_to_local(random_position) + Vector2(tilemap.tile_size.x, tilemap.tile_size.y)/2
				spawned_enemies.add_child(enemy)
				spawned = true
			else:
				attempts += 1
		### the original check and spawn code, is it a problem to pass the layer if it is a tilemaplayer
		if is_valid_spawn_location(Global.GRASS_LAYER, random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.position = tilemap.map_to_local(random_position) + Vector2(tilemap.tile_size.x, tilemap.tile_size.y)/2
			spawned_enemies.add_child(enemy)
			spawned = true
		else:
			attempts += 1
	if attempts >= max_attempts:
		print("Warning: Could not find a valid location")

#add player position as a non valid spawn point
#how to spawn from a specific location with a direction
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	### i put this in to check if it is an old tilemap node or new tilemaplayer node, since they do things different  ###
	if tilemap.is_a("TileMap"):
		#first check if it is an invalid tile
		if tilemap.get_cell_source_id(Global.WATER_LAYER, cell_coords) != -1 ||tilemap.get_cell_source_id(Global.BUILDING_LAYER, cell_coords) != -1 || tilemap.get_cell_source_id(Global.FOLIAGE_LAYER, cell_coords) != -1:
			return false
		#second check if valid tile
		if tilemap.get_cell_source_id(Global.GRASS_LAYER, cell_coords) != -1:
			return true
	else:	
	### for david only ###
	### you dont need this unless you are using tilemaplayer nodes ###
		if tilemapItems.get_cell_source_id(cell_coords) != -1 || tilemapWater.get_cell_source_id(cell_coords) != -1:
			return false
	#second check if valid tile
		if tilemap.get_cell_source_id(cell_coords) != -1:
			return true


func _on_timer_timeout() -> void:
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count += 1
