extends CharacterBody2D

#INFO
#figure out if its close to the player
#if its far , chase player
#if its really close, attack the player
# we need a distance to start attacking so they dont mob the player
#if its really far, roam, change direction everynow and then

######## fixed - enenmy no random motion when not chasing
######## !!!! change the collision layer mask so enemies dont pile up !!!!
# added raycast so we can tell if the enemy is facing the player
# if they are facing the player, and they are close enough, and they have bullets, they can shoot the player


#enemy variables
var health = 60 #i gave them less at stzrt but overtime they get up to 100
var max_health = 100
var regen_health = 1

#bullet stuff
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
@onready var ray_cast = $RayCast2D
#since enemy is spawned by spawner, we need the absolute path to the player node !!!!
@onready var player = get_tree().root.get_node("Main/Player")
var is_attacking = false

#signals
signal death

func _ready() -> void:
	rng.randomize()
	animation_sprite.modulate = Color(1, 1, 1, 1)
	#print("Enemy SPwaned at: ", position)
	

func _process(delta: float) -> void:
	#calculate health
	var updated_health = clamp(health + regen_health * delta, 0, max_health)
	#get the collider of the raycast ray
	#change the collision mask on the raycast node so it only is the player collision mask layer
	#i usually have 1 = tiles/background, 2= player, 3= enemy, 4=pickups, etc
	var target = ray_cast.get_collider()
	if target != null:
		#if we are colliding with the player and the player isn't dead
		if target.is_in_group("player"):
			#shooting anim
			is_attacking = true
			var animation  = "attack_" + returned_direction(new_direction)
			animation_sprite.play(animation)
			#now we need to spawn bullets

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
	# Turn RayCast2D toward movement direction  
	if direction != Vector2.ZERO:
		ray_cast.target_position = direction.normalized() * 50


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
	#do damage
#subtract damage amont from enemy
#send a signal to the enmy to update their helth
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
		player.update_xp(70)
		#emit a signal 
		death.emit()
		
		#when the enemy dies, there is a chance they will drop loot
		#the loot will be randomly be one of the 3 types of pickups
		if rng.randf() < 0.9:
			var pickup = Global.pickup_scene.instantiate()
			pickup.item = rng.randi() % 3 #we have three pickups in our enum
			# attach it to our pickup spawner, but wait until all the script action is done
			get_tree().root.get_node("Main/PickupSpawner/SpawnedPickups").call_deferred("add_child", pickup)
			pickup.position = position
		



func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_sprite.animation == "death_front":
		queue_free()
	is_attacking = false
	#if it is not the death animation that finished, it must be the attacking animations
	# Instantiate Bullet
	if animation_sprite.animation.begins_with("attack_"):
		var bullet = Global.bullet_scene.instantiate()
		bullet.group_to_hit = "player"
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		# Place it 8 pixels away in front of the enemy to simulate it coming from the guns barrel
		bullet.position = player.position + new_direction.normalized() * 8
		get_tree().root.get_node("Main").add_child(bullet)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_sprite.modulate = Color(1, 1, 1, 1)
