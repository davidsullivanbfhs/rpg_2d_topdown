extends CharacterBody2D


@export var speed = 50.0


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Top")
	
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	var movement = direction * speed * delta
	
	move_and_collide(movement)
