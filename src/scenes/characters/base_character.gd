extends KinematicBody2D

export var speed = 100

const ARRIVAL_DELTA = 12*12
onready var nav = get_tree().get_nodes_in_group("IslandNav")[0]
onready var status_gradient = load("res://scenes/characters/status_gradient.tres")


func get_random_pos_in_area(area):
	var x = (randi() % int((area[1].x-area[0].x))) + area[0].x
	var y = (randi() % int((area[1].y-area[0].y))) + area[0].y
	return Vector2(x,y)
