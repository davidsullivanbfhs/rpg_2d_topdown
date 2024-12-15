@tool

extends Area2D

### pickups health, stamina, ammo
enum Pickups { AMMO, STAMINA, HEALTH }
@export var item : Pickups

@onready var sprite = $Sprite2D

## texture assets
var ammo_texture = preload("res://Assets/Icons/shard_01g.png")
var stamina_texture = preload("res://Assets/Icons/potion_01d.png")
var health_texture = preload("res://Assets/Icons/potion_03a.png")


func _ready() -> void:
	if not Engine.is_editor_hint():
		if item == Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			sprite.set_texture(stamina_texture)

func _process(delta):
	if Engine.is_editor_hint():
		if item == Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			sprite.set_texture(stamina_texture)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#check what item it is
		#update our ammo health stamina
		body.add_pickup(item)
		#remove it
		queue_free()
