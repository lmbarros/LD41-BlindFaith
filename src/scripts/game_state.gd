extends Node

const NUM_WORSHIPERS = 5
const INITIAL_FAITH = 1000

var faith = INITIAL_FAITH 

var worshiper_scene = preload("res://scenes/characters/worshiper.tscn")

func init(island):
	faith = INITIAL_FAITH 
	randomize()
	create_worshipers(island)



func create_worshipers(island):
	for i in range(NUM_WORSHIPERS):
		var worshiper = worshiper_scene.instance()
		island.add_child(worshiper)
