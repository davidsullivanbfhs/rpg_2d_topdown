#### GLOBAL ################
extends Node

#Scene resources
#consumables
#@onready var pickups_scene = preload("res://Scenes/enemy.tscn")
#bullets
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
#enemies
@onready var enemy_scene = preload("res://Scenes/enemy.tscn")

#Tilemap layers
const WATER_LAYER = 0
const GRASS_LAYER = 1
const BUILDING_LAYER = 2
