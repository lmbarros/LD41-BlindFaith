extends Node2D

export var readiness = 0.0

func _process(delta):
	readiness += delta * 1.0/180
	readiness = clamp(readiness, 0.0, 1.0)
	$Readiness.text = str(int(readiness*100)) + "%"
