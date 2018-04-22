extends "res://scenes/characters/base_character.gd"

var health = 1.0

var decide_again_in_secs = 0.0

func _ready():
	$Status.rotation = -rotation
	position = $"../PosNonbelieversVillage".position
	add_to_group("Nonbelievers")


func _physics_process(delta):
	health += 1.0/120 * delta
	health = clamp(health, 0.0, 1.0)
	$Status/Health.modulate = status_gradient.interpolate(health)

	# AI
	decide_again_in_secs -= delta
	if decide_again_in_secs <= 0.0:
		decide_again_in_secs = rand_range(10.0, 30.0)
		move_to_random_location()

	# Movement
	if path.size() > 0:
		if position.distance_squared_to(path[0]) > ARRIVAL_DELTA:
			var velocity = (path[0] - position).normalized() * speed
			if velocity.length_squared() > 0:
				rotation = velocity.angle() + PI/2
				$Status.rotation = -rotation
			move_and_slide(velocity)
		else:
			path.remove(0)
			#if path.size() == 0:
			#	self.call(func_at_arrival, arg_at_arrival)



var path = [ ]

func move_to_random_location():
	var area = [ Vector2(27, 24), Vector2(43, 35) ]
	var x = randi() % int((area[1].x-area[0].x)) + area[0].x
	var y = randi() % int((area[1].y-area[0].y)) + area[0].y

	var target = Vector2(x, y) * 128 + Vector2(64, 64)
	path = nav.get_simple_path(position, target, false)


	#move_to_then_do(Vector2(x,y), "do_nothing", null)