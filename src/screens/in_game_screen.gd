extends Node

func _ready():
	TheState.init($Island)



func _process(delta):
	if TheState.faith <= 0:
		get_tree().change_scene("res://screens/game_over_screen.tscn")

	var num_worshipers = get_tree().get_nodes_in_group("Worshipers").size()
	if num_worshipers <= 0:
		get_tree().change_scene("res://screens/game_over_screen.tscn")

	var num_nonbelievers = get_tree().get_nodes_in_group("Nonbelievers").size()
	if num_nonbelievers <= 0:
		get_tree().change_scene("res://screens/victory_screen.tscn")



func _on_WarinessTimer_timeout():
	TheState.update_wariness()
