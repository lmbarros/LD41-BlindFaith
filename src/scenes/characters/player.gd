extends "res://scenes/characters/base_character.gd"


func _process(delta):
	# Natural faith decrease
	TheState.faith -= delta * 1.4
	
	# Miracles
	var the_miracle = TheState.miracles[TheState.selected_miracle]

	if Input.is_action_pressed("miracle"):
		$MiracleCircle.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		$MiracleCircle.self_modulate = Color(1.0, 1.0, 1.0, 0.4)

	if Input.is_action_just_released("miracle"):
		TheState.do_miracle()
		
	var miracle_scale = the_miracle.radius / 100.0
	$MiracleCircle.scale = Vector2(miracle_scale, miracle_scale)

	# Walk
	var velocity = Vector2()

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
		
	if velocity.length_squared() > 0:
		rotation = velocity.angle() + PI/2
		$MiracleCircle.rotation -= rotation

	# Move!
	move_and_slide(velocity)
