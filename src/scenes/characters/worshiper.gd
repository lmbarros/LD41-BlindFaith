extends "res://scenes/characters/base_character.gd"

enum State {
	JUST_CREATED,
	WANDERING,
	STOPPED,
}

func _ready():
	$Status.rotation = -rotation

	var pos = Vector2()

	match randi() % 3:
		0: pos = $"../PosHouse1".position
		1: pos = $"../PosHouse2".position
		2: pos = $"../PosHouse3".position
		
	position = pos
	
	add_to_group("Worshipers")



#
# Behavioral variables
#

# Gained by doing deeds, finishing jobs, defeating enemies, worshiping...
var fulfillment = 0.5

# Gained by eating, resting.
var energy = 0.5

# Gained by resting in a hospital.
var health = 0.5

#
# More state
#

# Disease or wounds
var disease = 0.02

#
# Moving
#

var path = []
var func_at_arrival = ""
var arg_at_arrival = null

func move_to_then_do(target_tile, func_to_do, arg):
	func_at_arrival = func_to_do
	arg_at_arrival = arg
	
	var target = target_tile * 128 + Vector2(64, 64)
	path = nav.get_simple_path(position, target, false)


func _physics_process(delta):
	# Internal state
	fulfillment -= 1.0/100 * delta
	energy -= 1.0/250 * delta
	health -= (1.0/30*disease) * delta
	
	$Status/Fulfillment.modulate = status_gradient.interpolate(fulfillment)
	$Status/Energy.modulate = status_gradient.interpolate(energy)
	$Status/Health.modulate = status_gradient.interpolate(health)
	$Status/Health/Disease.modulate = status_gradient.interpolate(1.0 - disease)
	
	# AI
	watch(delta)

	decide_again_in_secs -= delta
	
	if decide_again_in_secs <= 0:
		decide_what_to_do()

	# Movement
	if path.size() > 0:
		if position.distance_squared_to(path[0]) > ARRIVAL_DELTA:
			var velocity = (path[0] - position).normalized() * speed
			if velocity.length_squared() > 0:
				rotation = velocity.angle() + PI/2
				$Status.rotation = -rotation
			move_and_slide(velocity)
			
			energy -= delta * 1.0/180
			
		else:
			path.remove(0)
			if path.size() == 0:
				self.call(func_at_arrival, arg_at_arrival)

#
# AI
#

var decide_again_in_secs = 0.0

func decide_what_to_do():
	if randf() < 1.0 - energy:
		find_food()
		decide_again_in_secs = 60.0
	else:
		move_to_random_location()
		decide_again_in_secs = rand_range(10.0, 30.0)



func find_food():
	var area = [ Vector2(15, 15), Vector2(18, 18) ]
	var target_tile = get_random_pos_in_area(area)
	move_to_then_do(target_tile, "do_eat", null)

	
func move_to_random_location():
	var near_area = [ Vector2(12, 8), Vector2(22, 18) ]
	var medium_area = [ Vector2(11, 7), Vector2(29, 35) ]
	var far_area = [ Vector2(11, 7), Vector2(43, 35) ]
	
	var area = far_area
	var r = randf()
	if r < 0.55:
		area = near_area
	elif r < 0.90:
		area = medium_area
	
	var target_tile = get_random_pos_in_area(area)

	move_to_then_do(target_tile, "do_nothing", null)



func watch(delta):
	var player = get_tree().get_nodes_in_group("Player")[0]
	for i in range($Vision.get_child_count()):
		var ray_cast = $Vision.get_child(i)
		ray_cast.force_raycast_update()

		if ray_cast.is_colliding() and ray_cast.get_collider() == player:
			$VisionLine.points[1] = to_local(ray_cast.get_collision_point())
			$VisionLine.visible = true
			
			TheState.faith -= delta * 150
			
			return

	$VisionLine.visible = false



func do_eat(dummy):
	if TheState.food > 0:
		TheState.food -= 1
		energy += 0.9
		energy = clamp(energy, 0.0, 1.0)

	decide_what_to_do()

	
func do_nothing(dummy):
	pass
