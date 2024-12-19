extends Node2D


#get current spawn count
#check tilemap  for spawnable locations

#reference to our empty node2d container for spawned enemies
@onready var spawned_pickups = $SpawnedPickups
@onready var tilemap = $"../TileMap"



#### pickup vars ####
#set max pickups
@export var max_items = 20

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn between 5 and 10 pickups at the beginning, dont need a timer
	var spawn_pickup_amount = rng.randi_range(10, max_items) #changed this to random integar
	print("spawn_pickup_amount: ", spawn_pickup_amount)
	spawn_pickups(spawn_pickup_amount)  
	
	
func spawn_pickups(amount):
	var attempts = 0
	var max_attempts = 100
	var spawned = 0 #changed this to a int to check against amount
	
	while spawned < amount and attempts < max_attempts:
		attempts += 1 # increment this
		### a second way to specify where to spawn enemies using a tilemap layer as a spawn layer
		## create an array of used cells on a layer 
		var groundtiles = tilemap.get_used_cells(Global.SPAWN_LAYER)
		## shuffle the array, 
		groundtiles.shuffle()
		## pick a position until max-enemy is reached
		var random_position2 = groundtiles.pick_random()
		#random number for position in x and y
		var random_position = Vector2(rng.randi() % tilemap.get_used_rect().size.x,  rng.randi() % tilemap.get_used_rect().size.y)
		### this check is just for me because i am using tilemaplayers

		if is_valid_spawn_location(Global.SPAWN_LAYER, random_position2):
			var pickup = Global.pickup_scene.instantiate()
			# pick a random item to spawn from the enum in the globals script
			pickup.item = Global.Pickups.values()[randi() % 3]
			pickup.position = tilemap.map_to_local(random_position2) + Vector2(tilemap.tile_set.tile_size.x, tilemap.tile_set.tile_size.y)/2
			spawned_pickups.add_child(pickup)
			spawned += 1 #add another spawn
			#print("spawned an item")
			

	if attempts >= max_attempts:
		print("Warning: Could not find a valid location")

#add player position as a non valid spawn point
#how to spawn from a specific location with a direction
#check tilemap  for spawnable locations
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	### i put this in to check if it is an old tilemap node or new tilemaplayer node, since they do things different  ###
		#first check if it is an invalid tile
	if tilemap.get_cell_source_id(Global.WATER_LAYER, cell_coords) != -1 ||tilemap.get_cell_source_id(Global.BUILDING_LAYER, cell_coords) != -1:
		return false
		#second check if valid tile
	if tilemap.get_cell_source_id(Global.GRASS_LAYER, cell_coords) != -1:
		return true
