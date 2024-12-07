extends CanvasLayer

@onready var health_value = $Health/Value
@onready var stamina_value = $Stamina/Value
@onready var player = $"../Player"


func _on_player_health_updated() -> void:
	#print("updated health")
	health_value.size.x = 98 * player.health / player.max_health


func _on_player_stamina_updated() -> void:
	#print("updated stamina")
	stamina_value.size.x = 98 * player.stamina / player.max_stamina
