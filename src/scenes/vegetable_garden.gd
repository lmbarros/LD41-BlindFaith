extends Node2D

export var readyness = 0.0

func _process(delta):
	readyness += delta * 1.0/180
	readyness = clamp(readyness, 0.0, 1.0)
	$Readyness.text = str(int(readyness*100)) + "%"
