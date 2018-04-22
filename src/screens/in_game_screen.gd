extends Node

func _ready():
	TheState.init($Island)



func _process(delta):
	if TheState.faith <= 0:
		get_tree().change_scene("res://screens/game_over_screen.tscn")



func _on_WarinessTimer_timeout():
	TheState.update_wariness()
