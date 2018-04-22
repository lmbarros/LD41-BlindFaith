extends Node

var can_go = false

func _input(event):
	if can_go && event is InputEventKey or event is InputEventJoypadButton:
    	get_tree().change_scene("res://screens/in_game_screen.tscn")

func _on_Timer_timeout():
	can_go = true
