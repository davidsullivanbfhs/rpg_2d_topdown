extends CharacterBody2D

#figure out if its close to the player
#if its far , chase player
#if its really close, attack the player
#if its really far, roam, change direction everynow and then

########enenmy no random motion when not chasing

#enemy variables
var health = 100
var max_health = 100
var regen_health = 1

#bullet stuff
#@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
var bullet_damage = 30
var bullet_reload_time = 1000
var bullet_fired_time = 0.5 #when did they fire

@export var speed = 50.0
var direction: Vector2
var new_direction = Vector2(0, 1)

var rng = RandomNumberGenerator.new()

var timer = 0

var animation
@onready var timer_node = $Timer
@onready var animation_player = $AnimationPlayer
@onready var animation_sprite = $AnimatedSprite2D
@onready var player = $"../Player"
var is_attacking = false

#signals
signal death

func _ready() -> void:
	rng.randomize()
	animation_sprite.modulate = Color(1, 1, 1, 1)
	

func _process(delta: float) -> void:
	#calculate health
	var updated_health = clamp(health + regen_health * delta, 0, max_health)

func _physics_process(delta: float) -> void:
	var movement = speed * direction * delta
	var collision = move_and_collide(movement)
	
	if collision != null and collision.get_collider().name != "Player":
		#print("hit something")
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		timer = rng.randf_range(2, 5)
	else:
		#print("hit the player")
		timer = 0
		
	if !is_attacking:
		enemy_animations(direction)


func _on_timer_timeout() -> void:
	var player_distance = player.position - position
	#attack
	if player_distance.length() <= 20:
		new_direction = player_distance.normalized()
		sync_new_direction()
		direction = Vector2.ZERO
	#chase
	elif player_distance.length() <= 100 and timer == 0:
		direction = player_distance.normalized()
		sync_new_direction()
	#random roam
	elif timer == 0:
		var random_direction = rng.randf()
		#chill
		if random_direction < 0.05:
			direction = Vector2.ZERO
		#hustle
		elif random_direction < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
		sync_new_direction()


func enemy_animations(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + returned_direction(new_direction)
		
		animation_sprite.play(animation)
	else:
		animation = "idle_" + returned_direction(new_direction)
		
		animation_sprite.play(animation)
		
		
func returned_direction(direction: Vector2):
	#print(direction)
	var normalized_direction = direction.normalized()#normalizing seems redundant here since it is normalized earlier
	var default_return = "side"
	#print(normalized_direction)
	#enemy doesnt have a key telling us which direction to go
	#so we need to decide based on what values are greater in x or y
	if abs(normalized_direction.x) > abs(normalized_direction.y):
		if normalized_direction.x > 0:
			animation_sprite.flip_h = false
			return "side"
		else:
			animation_sprite.flip_h = true
			return "side"
	if normalized_direction.y > 0 :
		return "front"
	elif normalized_direction.y < 0 :
		return "back"

	return default_return
	

func sync_new_direction():
	if direction != Vector2.ZERO:
		new_direction = direction.normalized()


func hit(damage):
	health -=  damage
	#play hit animation
	if health > 0:
		is_attacking = true
		#trying to make the cactus stop moving for a second
		direction = Vector2.ZERO
		#play the hit animation
		animation_sprite.play("hit_front")
		print(animation_sprite.animation)
		#change the look
		animation_player.play("damaged")
		#get
		await get_tree().create_timer(2).timeout
		is_attacking = false
		
	else:
		timer_node.stop()
		set_process(false)
		#make sure they cant shoot
		is_attacking = true
		direction = Vector2.ZERO
		#play the death animation
		animation_sprite.play("death_front")
		
		#emit a signal 
		death.emit()
		#queue_free



func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_sprite.animation == "death_front":
		get_tree().queue_delete(self)
	is_attacking = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_sprite.modulate = Color(1, 1, 1, 1)
