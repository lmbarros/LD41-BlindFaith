extends Node

const NUM_WORSHIPERS = 5
const NUM_NONBELIEVERS = 20
const INITIAL_FAITH = 1000.0

var faith = INITIAL_FAITH 
var selected_miracle = Miracle.HEAL


enum Miracle {
	HEAL
}

var miracles = {
	Miracle.HEAL: {
		name = "Heal",
		description = "Gives health to nearby worshipers.",
		cost = 200,
		radius = 200,
	}
}

onready var miracle_particles = load("res://scenes/fx/miracle_particles.tscn")

var worshiper_scene = preload("res://scenes/characters/worshiper.tscn")
var nonbeliever_scene = preload("res://scenes/characters/nonbeliever.tscn")

func init(island):
	faith = INITIAL_FAITH 
	randomize()
	create_worshipers(island)
	create_nonbelievers(island)


func create_worshipers(island):
	for i in range(NUM_WORSHIPERS):
		var worshiper = worshiper_scene.instance()
		island.add_child(worshiper)

func create_nonbelievers(island):
	for i in range(NUM_NONBELIEVERS):
		var nonbeliever = nonbeliever_scene.instance()
		island.add_child(nonbeliever)


#
# Miracles
#

func do_miracle():
	var m = miracles[selected_miracle]

	if m.cost >= faith:
		return
	
	faith -= m.cost

	match selected_miracle:
		Miracle.HEAL: do_miracle_heal(m)


func do_miracle_heal(m):
	var targets = get_worshipers_within_radius(m.radius)

	var healed_amount = 0.0

	for w in targets:
		var health_before = w.health
		w.health = clamp (w.health + 0.75, 0.0, 1.0)
		var heal_delta = w.health - health_before
		healed_amount += heal_delta
		
		var fx = miracle_particles.instance()
		fx.amount = 2 + 35 * heal_delta
		w.add_child(fx)
		fx.restart()

	faith += healed_amount * m.cost * 1.08 # fully healing someone has a net gain


func get_worshipers_within_radius(r):
	var player = get_tree().get_nodes_in_group("Player")[0]
	var all_worshipers = get_tree().get_nodes_in_group("Worshipers")
	var targets = [ ]
	for w in all_worshipers:
		if player.position.distance_to(w.position) < r:
			targets.append(w)

	return targets
