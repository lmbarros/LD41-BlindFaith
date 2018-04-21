extends "res://scenes/characters/base_character.gd"


func _process(delta):
	var velocity = Vector2()

	# Walk
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	# Rotate before magnet influence
	if velocity.length_squared() > 0:
		rotation = velocity.angle() + PI/2

	# Move!
	move_and_slide(velocity)
