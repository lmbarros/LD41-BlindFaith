extends "res://scenes/characters/base_character.gd"

func _ready():
	$Status.rotation = -rotation
	$Status/Action.text = ""


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
var disease = 0.2

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
	if is_dying:
		return

	# Internal state
	fulfillment -= 1.0/360 * delta
	health -= (1.0/30*disease) * delta
	
	fulfillment = clamp(fulfillment, 0.0, 1.0)
	energy = clamp(energy, 0.0, 1.0)
	health = clamp(health, 0.0, 1.0)

	$Status/Fulfillment.modulate = status_gradient.interpolate(fulfillment)
	$Status/Energy.modulate = status_gradient.interpolate(energy)
	$Status/Health.modulate = status_gradient.interpolate(health)
	$Status/Health/Disease.modulate = status_gradient.interpolate(1.0 - disease)
	
	if health <= 0.0:
		die()
	
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
			
			energy -= delta * 1.0/300
			
		else:
			path.remove(0)
			if path.size() == 0:
				$Status/Action.text = "Idling"
				self.call(func_at_arrival, arg_at_arrival)

#
# AI
#

var decide_again_in_secs = 0.0

func decide_what_to_do():
	decide_again_in_secs = 60.0

	if randf() < disease + 0.25:
		go_to_the_hospital()
	elif randf() < 1.0 - health + 0.15:
		go_to_the_hospital()
	elif randf() < 1.0 - energy:
		find_food()
	elif is_motivated() and is_energized() and is_any_garden_ready():
		go_harvest()
	elif is_motivated() and is_energized() and is_healthy() and not too_crowded():
		go_procreate()
	else:
		move_to_random_location()
		decide_again_in_secs = rand_range(10.0, 30.0)



func is_motivated():
	return randf() < fulfillment



func is_energized():
	return randf() < energy



func is_healthy():
	return randf() < health



const MAX_BELIEVERS = 25
func too_crowded():
	var population = get_tree().get_nodes_in_group("Worshipers").size()
	return population >= MAX_BELIEVERS



var ready_gardens = [ ]

func is_any_garden_ready():
	ready_gardens = []

	var gardens = get_tree().get_nodes_in_group("Gardens")	
	for g in gardens:
		if g.readiness >= 1.0:
			ready_gardens.append(g)

	return ready_gardens.size() > 0



func find_food():
	$Status/Action.text = "Going to eat"
	var area = [ Vector2(15, 15), Vector2(18, 18) ]
	var target_tile = get_random_pos_in_area(area)
	move_to_then_do(target_tile, "do_eat", null)



func go_to_the_hospital():
	$Status/Action.text = "Going to heal"
	var area = [ Vector2(18, 11), Vector2(21, 14) ]
	var target_tile = get_random_pos_in_area(area)
	move_to_then_do(target_tile, "do_heal", null)



func go_procreate():
	$Status/Action.text = "Going to procreate"
	var area = [ Vector2(14, 11), Vector2(20, 16) ]
	var target_tile = get_random_pos_in_area(area)
	move_to_then_do(target_tile, "do_procreate", null)



func go_harvest():
	$Status/Action.text = "Going to harvest"
	var gardens = get_tree().get_nodes_in_group("Gardens")

	if ready_gardens.size() == 0:
		decide_again_in_secs = 2.0
		return

	var garden = ready_gardens[randi() % ready_gardens.size()]
	var area = [ Vector2(15, 13), Vector2(18, 15) ]
	var target_tile = get_random_pos_in_area(area)
	move_to_then_do(target_tile, "do_harvest", garden)



func move_to_random_location():
	$Status/Action.text = "Wandering"
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
			
			TheState.faith -= delta * 225
			
			return

	$VisionLine.visible = false



func do_eat(dummy):
	$Status/Action.text = "Eating"
	if TheState.food > 0:
		TheState.food -= 1
		energy += 0.9
		energy = clamp(energy, 0.0, 1.0)

	decide_again_in_secs = 4.0



func do_heal(dummy):
	$Status/Action.text = "Being healed"
	health += 0.4
	health = clamp(health, 0.0, 1.0)
	disease -= 0.1
	disease = clamp(disease, 0.0, 1.0)
	decide_again_in_secs = 7.0



func do_harvest(garden):
	if garden.readiness >= 1.0:
		$Status/Action.text = "Harvesting"
		TheState.food += rand_range(5, 10)
		decide_again_in_secs = 10.0
		garden.readiness = 0.0
		fulfillment += 0.4
		fulfillment = clamp(fulfillment, 0.0, 1.0)
	else:
		$Status/Action.text = "Waiting"
		decide_again_in_secs = 1.0



onready var worshiper_scene = preload("res://scenes/characters/worshiper.tscn")

func do_procreate(garden):
	if not too_crowded():
		$Status/Action.text = "Procreating"
		var worshiper = worshiper_scene.instance()
		$"..".add_child(worshiper)
		energy -= 0.1
		energy = clamp(energy, 0.0, 1.0)
		fulfillment += 0.85
		fulfillment = clamp(fulfillment, 0.0, 1.0)
		
		decide_again_in_secs = 7.5
	else:
		$Status/Action.text = "Waiting"
		decide_again_in_secs = 1.0



func do_nothing(dummy):
	pass



func _on_DieTimer_timeout():
	queue_free()




func go_wage_war():
	$Status/Action.text = "Waging war"
	decide_again_in_secs = 120.0

	$AttackPlayer.play()
	
	var nonbelievers = get_tree().get_nodes_in_group("Nonbelievers")
	var n = nonbelievers[randi() % nonbelievers.size()]

	n.stay_and_defend()
	
	var x = int(n.position.x / 128)
	var y = int(n.position.y / 128)
	
	move_to_then_do(Vector2(x,y), "attack_nonbeliever", weakref(n))



func attack_nonbeliever(nonbeliever):
	if not nonbeliever.get_ref():
		# Target already killed by someone else
		decide_what_to_do_while_in_combat()
		return

	$Status/Action.text = "Attacking"

	var foe = nonbeliever.get_ref()

	foe.health -= rand_range(0.0, 1.1) * energy
	foe.health = clamp(foe.health, 0.0, 1.0)
	fulfillment += 0.35
	fulfillment = clamp(fulfillment, 0.0, 1.0)

	energy -= 0.15

	if foe.health == 0.0:
		fulfillment = 1.0

	# Counter-attack
	if foe.health > 0.0:
		disease += rand_range(0.0, 0.1)
		disease = clamp(disease, 0.0, 1.0)

		health -= rand_range(0.0, 0.35)
		health = clamp(health, 0.0, 1.0)

	if health > 0.0:
		decide_what_to_do_while_in_combat()



func decide_what_to_do_while_in_combat():
	if disease >= 0.35 or health <= 0.5:
		go_to_the_hospital()
	elif energy < 0.3:
		find_food()
	else:
		go_wage_war()
