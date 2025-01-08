extends CharacterBody2D

###################### TODO ##################################
###### DONE   Add diagonal movement
###### DONE add shooting, get animation, play animation, reset is_attacking on animation finish
######## DONE add sprinting
######### DONE add recoil, get the direction and add a negative force
#DONE make stamina work better 
#online multiplayer
# procedural world generation
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
# to fix ysort problem, set player and enemies to zindex 2, ysort layer to zindex 1, and all others to 0
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###

#player variables
var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 1

### pickups health, stamina, ammo
enum Pickups { AMMO, STAMINA, HEALTH }
var health_pickup_amount = 0
var stamina_pickup_amount = 0
var ammo_amount = 0

#custom signals
signal health_updated
signal stamina_updated

signal ammo_amount_updated
signal health_amount_updated
signal stamina_amount_updated
signal player_dead

signal xp_updated
signal level_updated
signal xp_requirements_updated

@export var speed = 50.0
@export var recoil = -5.0
@export var stamina_decrease = 1

 # XP and levelling
var xp = 0 
var level = 1 
var xp_requirements = 100

@onready var animation_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
var new_direction: Vector2 = Vector2.ZERO
var animation
var is_attacking = false #controls if player can move
## an attempt to not let the player get hit after they are dead
var dead = false

###  bullet stuff  ###
#moved to global script
#@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
var bullet_damage = 30
var bullet_reload_time = 1000
var bullet_fired_time = 0.5 #when did they fire

func _ready() -> void:
	animation_sprite.modulate = Color(1, 1, 1, 1)
	set_process(true)
	set_physics_process(true)
	## need to update the ammo to 6 at the beginning
	## perhaps this isnt showing because ui isnt ready to listen yet??
	ammo_amount = 6
	await get_tree().create_timer(1).timeout
	ammo_amount_updated.emit(ammo_amount)
	get_node("CollisionShape2D").disabled = false    # disable
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta: float) -> void:
	#calculate health
	var updated_health = clamp(health + regen_health * delta, 0, max_health)
	################## clamp the value ##################
	if updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)
	#calculate stamina, min makes it stay under the max value. need to clamp so it stays above 0
	var updated_stamina = clamp(stamina + regen_stamina * delta, 0, max_stamina)
	################## clamp the value ##################
	if updated_stamina != stamina:
		stamina = updated_stamina
		############### need to make sure to receive these values in our listener function #########
		stamina_updated.emit(stamina, max_stamina) #stamina, max_stamina
	
	
func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Top")
	
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	if Input.is_action_pressed("Sprint"):	
		if stamina >= 0:
			speed = 100
			animation_sprite.speed_scale = 2
			stamina = stamina - stamina_decrease ### make this a variable
			stamina_updated.emit(stamina, max_stamina) # stamina, max_stamina
	elif Input.is_action_just_released("Sprint"):
		speed = 50
		animation_sprite.speed_scale = 1
	
	##make them slow down if they have used up their stamina, even if they have sprint button pressed
	if stamina <= 0:
		speed = 50
		animation_sprite.speed_scale = 1
	#var movement = direction * speed * delta
	#print(is_attacking)
	if is_attacking == false:
		var movement = direction * speed * delta
		move_and_collide(movement)
		player_animations(direction)
		
	######### attempting recoil
	else:
		#direction will be zero, so need to find the facing direction and negate it, easy method is use last direction from new_direction
		var movement = new_direction * delta * recoil
		move_and_collide(movement)

func player_animations(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		animation = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)
		
func returned_direction(direction: Vector2):
	var normalized_direction = direction.normalized()#normalizing seems redundant here since it is normalized earlier
	var default_return = "side"
	#print(normalized_direction)
	if normalized_direction.y > 0 and normalized_direction.x == 0 :
		return "front"
	elif normalized_direction.y < 0 and normalized_direction.x == 0 :
		return "back"
	elif normalized_direction.x > 0 and normalized_direction.y == 0:
		animation_sprite.flip_h = false
		return "side"
	elif normalized_direction.x < 0  and normalized_direction.y == 0:
		animation_sprite.flip_h = true
		return "side"
	#### diagonal movement
	#right down
	elif normalized_direction.y > 0 and normalized_direction.x > 0 :
		animation_sprite.flip_h = false
		return "angleDown"
	#left down
	elif normalized_direction.y > 0 and normalized_direction.x < 0 :
		animation_sprite.flip_h = true
		return "angleDown"
	#right up
	elif normalized_direction.y < 0 and normalized_direction.x > 0 :
		animation_sprite.flip_h = false
		return "angleUp"
	#left up
	elif normalized_direction.y < 0 and normalized_direction.x < 0 :
		animation_sprite.flip_h = true
		return "angleUp"
	
	return default_return


func _input(event):
	if event.is_action_pressed("Shoot"):
		var now = Time.get_ticks_msec()
		if now >= bullet_fired_time and ammo_amount > 0:
			is_attacking = true
			animation = "attack_" + returned_direction(new_direction)
			animation_sprite.play(animation)
			#update the time
			bullet_fired_time = now + bullet_reload_time
			#update the ammo and send signal to ui
			ammo_amount = ammo_amount - 1
			ammo_amount_updated.emit(ammo_amount)
#using health consumables
	elif event.is_action_pressed("ConsumeHealthPotion"):
		if health > 0 && health_pickup_amount > 0:
			health_pickup_amount = health_pickup_amount - 1
			health = min(health + 50, max_health)
			health_updated.emit(health, max_health)
			health_amount_updated.emit(health_pickup_amount) 
	#using stamina consumables      
	elif event.is_action_pressed("ConsumeStaminaPotion"):
		if stamina > 0 && stamina_pickup_amount > 0:
			stamina_pickup_amount = stamina_pickup_amount - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_updated.emit(stamina, max_stamina)
			stamina_amount_updated.emit(stamina_pickup_amount)
		


func _on_animated_sprite_2d_animation_finished() -> void:

	#print("Finished animation")
	is_attacking = false
	#moved all the bullet stuff to frame changed function so shooting would be snappier


func _on_animated_sprite_2d_frame_changed() -> void:
	#instantiate bullet
	if animation_sprite.animation.begins_with("attack_")&& animation_sprite.frame == 2:
		var bullet = Global.bullet_scene.instantiate()
		bullet.group_to_hit = "enemies"
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		#if they shoot at the beginning, they have no direction yet, so give a direction
		if bullet.direction == Vector2.ZERO:
			bullet.direction = Vector2(1, 0)
		bullet.position = position + (bullet.direction * 8)#need to figure out how to shoot a bullet without hitting themselves
		if bullet.direction == Vector2.ZERO:
			bullet.position = position
		get_tree().root.get_node("Main").add_child(bullet)

# find type, add amount, emit signal
func add_pickup(item):
	if item == Pickups.AMMO:
		ammo_amount = ammo_amount + 6
		ammo_amount_updated.emit(ammo_amount)
	### add other two
	if item == Pickups.HEALTH:
		health_pickup_amount = health_pickup_amount + 1 # + 1 health drink
		health_amount_updated.emit(health_pickup_amount)
		#print("health val:" + str(health_pickup_amount))
	if item == Pickups.STAMINA:
		stamina_pickup_amount = stamina_pickup_amount + 1 # + 1 stamina drink
		stamina_amount_updated.emit(stamina_pickup_amount)
		#print("stamina val:" + str(stamina_pickup_amount))
	update_xp(5)

# ------------------- Damage & Death ------------------------------
	#does damage to our player
func hit(damage):
	if dead:
		return
	is_attacking = true
	health -= damage    
	health_updated.emit(health, max_health)
	if health > 0:
		#damage
		animation_sprite.play("hit_front")
		animation_player.play("damaged")
	else:
		#death
		set_process(false)
		set_physics_process(false)
		#turn off collision
		#$CollisionShape2D.disabled = true   # disable
		animation_sprite.play("death_front")
		animation_player.play("damaged")
		dead = true
		
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if health <= 0:
		#emit a signal to main after animation plays 
		player_dead.emit()
		#print("health: ", health)
	animation_sprite.modulate = Color(1, 1, 1, 1)
	is_attacking = false
	
	
# ----------------- Level & XP ------------------------------
#updates player xp
func update_xp(value):
	xp += value
#check if player leveled up after reaching xp requirements
	if xp >= xp_requirements:
		#allows input
		#set_process_input(true)
		#pause the game
		#get_tree().paused = true
		#make popup visible
		#level_popup.visible = true
		#reset xp to 0
		xp = 0
		#increase the level and xp requirements
		level += 1
		xp_requirements *= 2
		#update their max health and stamina
		max_health += 10 
		max_stamina += 10 
		#give the player some ammo and pickups
		ammo_amount += 10 
		health_pickup_amount += 5
		stamina_pickup_amount += 3
		#increase amount of enemies (do this in the main level script)
	#emit signals
	xp_requirements_updated.emit(xp_requirements)   
	xp_updated.emit(xp)
	level_updated.emit(level)
