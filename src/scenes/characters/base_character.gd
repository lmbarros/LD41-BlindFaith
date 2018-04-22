extends KinematicBody2D

export var speed = 100

const ARRIVAL_DELTA = 12*12
onready var nav = get_tree().get_nodes_in_group("IslandNav")[0]
onready var status_gradient = load("res://scenes/characters/status_gradient.tres")
