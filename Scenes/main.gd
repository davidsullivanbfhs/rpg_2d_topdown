extends Node2D

#####################  TODO ################################
## think about where player var info should be stored
## should gui be its own scene and own the code that changes it?
## DONE: fire bullets, 
## DONE: spawn pickups and change inventory
## add keys for using health and stamina potions
## DONE: spawn enemies
## npcs, dialog, quests
## hazards?
############################################################

#if you mark a node as having a unique name, you can use % to refer to the node
#this will work even if you change the parents
@onready var animation_player = $AnimationPlayer
@onready var health_bar_value = %HealthBar
@onready var stamina_bar_value = %StaminaBar
@onready var player = $Player
### we have to add variables for our ui collectible amounts
@onready var health_potion_amount
@onready var stamina_potion_amount
@onready var ammo_amount
# xp refs ## THESE SHOULD BE STORED IN PLAYER I THINK
#@onready var xp_amount
#@onready var xp_amount_req 
### LevelAmount ## THESE ARE STORED IN PLAYER
#@onready var level # the current level
#@onready var level_amount # amount needed to increase the level SEEMS LIKE THE SAME AS XP_AMOUNT_rEQ
@onready var level_popup = %LevelPopupPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect to all the signals to pass the info on to the ui
	player.health_updated.connect(_on_player_health_updated)
	player.stamina_updated.connect(_on_player_stamina_updated)
	player.ammo_amount_updated.connect(_on_player_ammo_amount_updated)
	player.stamina_amount_updated.connect(_on_player_stamina_amount_updated)
	player.health_amount_updated.connect(_on_player_health_amount_updated)
	player.player_dead.connect(_on_player_player_dead)
	player.xp_updated.connect(_on_player_update_xp_ui)
	player.xp_requirements_updated.connect(_on_player_update_xp_requirements_ui)
	player.level_updated.connect(_on_player_update_level_ui)
	%GameOverPanel.modulate = Color(0, 0, 0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_health_updated(health, max_health) -> void:
	health_bar_value.value = 100 * health / max_health


#### the functions need to receive the same arguments that were sent by the emitter ##########
func _on_player_stamina_updated(stamina, max_stamina) -> void:
	#print("changing the bar", stamina)
	stamina_bar_value.value = 100 * stamina / max_stamina
	

func _on_player_ammo_amount_updated(ammo_amount) -> void:
	%AmmoLabel.text = str(ammo_amount)
	
	
func _on_player_health_amount_updated(health_potion_amount) -> void:
	%RevivesLabel.text = str(health_potion_amount)
	
	
func _on_player_stamina_amount_updated(stamina_potion_amount) -> void:
	%StaminaLabel.text = str(stamina_potion_amount)
	
	
func _on_player_player_dead() -> void:
	animation_player.play("game_over")


#return xp
func _on_player_update_xp_ui(xp):
	#return something like 0
	%XPvalue.text = str(xp) + " / " + str(player.xp_requirements)
	print(xp)
#check if player leveled up after reaching xp requirements
	if xp >= player.xp_requirements:
		#allows input
		set_process_input(true)
		#pause the game
		get_tree().paused = true
		#make popup visible
		level_popup.visible = true
		print("make level visible: ", level_popup.visible)
		#reset xp to 0
		xp = 0
		#increase the level and xp requirements
		player.level += 1
		player.xp_requirements *= 2
####  if these values are kept in the player
####  maybe these values should be kept in a global?
		#update their max health and stamina
		player.max_health += 10 
		player.max_stamina += 10 

		#give the player some ammo and pickups
		player.ammo_pickup += 10 
		player.health_pickup += 5
		player.stamina_pickup += 3

		#update signals for Label values
		player.health_updated.emit(player.health, player.max_health)
		player.stamina_updated.emit(player.stamina, player.max_stamina)
		player.ammo_pickups_updated.emit(player.ammo_pickup)
		player.health_pickups_updated.emit(player.health_pickup)
		player.stamina_pickups_updated.emit(player.stamina_pickup)
		player.xp_updated.emit(xp)
		player.level_updated.emit(player.level)

		#reflect changes in Label
		%LevelGained.text = "LVL: " + str(player.level)
		%HealthIncreaseGained.text = "+ MAX HP: " + str(player.max_health)
		%StaminaIncreaseGained.text = "+ MAX SP: " + str(player.max_stamina)
		%HealthPickupsGained.text = "+ HEALTH: 5" 
		%StaminaPickupsGained.text = "+ STAMINA: 3" 
		%AmmoPickupsGained.text = "+ AMMO: 10" 

	#emit signals
	#player.xp_requirements_updated.emit(player.xp_requirements)   
	#player.xp_updated.emit(xp)
	#player.level_updated.emit(level)

#return xp_requirements
func _on_player_update_xp_requirements_ui(xp_amount_req_passed):
	#return something like / 100
	player.xp_requirements = xp_amount_req_passed
	

# Return level
func _on_player_update_level_ui(level):
	#return something like 0
	%Lvlvalue.text = str(level)
	#increase enemy spawn
	$EnemySpawner.max_enemies += 1
