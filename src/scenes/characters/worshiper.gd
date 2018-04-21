extends "res://scenes/characters/base_character.gd"

#
# Behavioral variables
#

# Gained by doing deeds, finishing jobs, defeating enemies, 
var fulfilment = 0.5

# Gained by eating.
var energy = 0.5

# Gained by resting in a hospital.
var health = 0.5

#
# Moving
#

const ARRIVAL_DELTA = 12*12
onready var nav = get_tree().get_nodes_in_group("IslandNav")[0]
var path = []
var func_at_arrival = ""
var arg_at_arrival = null

func move_to_then_do(target_tile, func_to_do, arg):
	func_at_arrival = func_to_do
	arg_at_arrival = arg
	
	var target = target_tile * 128 + Vector2(64, 64)
	print(position)
	print(target)
	path = nav.get_simple_path(position, target, false)


func _ready():
	move_to_then_do(Vector2(24, 19), "i_am_there", ["P1", 171])


func i_am_there(p):
	print("I arrived, with params " + str(p[0]) + " / " + str(p[1]))


func _process(delta):
	if path.size() > 0:
		if position.distance_squared_to(path[0]) > ARRIVAL_DELTA:
			var velocity = (path[0] - position).normalized() * speed
			if velocity.length_squared() > 0:
				rotation = velocity.angle() + PI/2
			move_and_slide(velocity)
		else:
			path.remove(0)
			if path.size() == 0:
				self.call(func_at_arrival, arg_at_arrival)
