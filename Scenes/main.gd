extends Node2D

#####################  TODO ################################
## think about where player var info should be stored
## should gui be its own scene and own the code that changes it?
## fire bullets, 
## spawn pickups and change inventory
## spawn enemies
## npcs, dialog, quests
## hazards?
############################################################

#if you mark a node as having a unique name, you can use % to refer to the node
#this will work even if you change the parents
@onready var health_bar_value = %HealthBar
@onready var stamina_bar_value = %StaminaBar
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_updated.connect(_on_player_health_updated)
	player.stamina_updated.connect(_on_player_stamina_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_health_updated(health, max_health) -> void:
	health_bar_value.value = 100 * health / max_health


#### the functions need to receive the same arguments taht were sent by the emitter ##########
func _on_player_stamina_updated(stamina, max_stamina) -> void:
	print("changing the bar", stamina)
	stamina_bar_value.value = 100 * stamina / max_stamina