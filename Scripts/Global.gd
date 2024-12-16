#### GLOBAL ################
extends Node

#Scene resources
#consumables
#@onready var pickups_scene = preload("res://Scenes/enemy.tscn")
#bullets
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
#enemies
@onready var enemy_scene = preload("res://Scenes/enemy.tscn")
#pickups
@onready var pickup_scene = preload("res://Scenes/pickup.tscn")

# Pickups
enum Pickups { AMMO, STAMINA, HEALTH }

#Tilemap layers
const WATER_LAYER = 0
const GRASS_LAYER = 1
const BUILDING_LAYER = 2
const SPAWN_LAYER = 3
