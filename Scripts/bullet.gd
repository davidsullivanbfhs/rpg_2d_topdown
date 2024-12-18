extends Area2D
#spawn at player gun
#move in the direction the player faces
#queue free after the timer timeout
#check if it hits something
#if they hit the enemy deal damage
#if it hits tile obstacle delete it.

@onready var tilemap = get_tree().root.get_node("Main/TileMap")
#@onready var tilemap_object = get_tree().root.get_node("Main/Items")
var direction : Vector2
var speed = 100
#should damage amount be in bullet or enemy?
var damage = 30

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position + speed * delta * direction

func _on_body_entered(body: Node2D) -> void:
	#if it collides with player, do nothing (return)
	if body.name == "Player":
		return
	#if it collides with the tilemap, check if it is a layer
	if body.name == "Tilemap": 
		if tilemap.get_layer_name(0) == "Water": # <-name of your tilemap layer that has collisions
			return
		if tilemap.get_layer_name(1) == "Things": # <-name of your tilemap layer that has collisions
			pass
	if body.name == "Items": #the name of your tilemap
		return
	#if it is in group enemy, deal damage	
	if body.is_in_group("enemies"):
		body.hit(damage)
		#do damage
		#subtract damage amont from enemy
		#send a signal to the enmy to update their helth
	#whatever happens, the bullet should explode and queue free
	direction = Vector2.ZERO
	animated_sprite.play("impact")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "impact":
		get_tree().queue_delete(self)


func _on_timer_timeout() -> void:
	animated_sprite.play("impact")
