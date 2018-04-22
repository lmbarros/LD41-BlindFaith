extends CanvasLayer

func _process(delta):
	$Panel/Faith.text = "Faith: " + str(int(TheState.faith))
	
	var m = TheState.miracles[TheState.selected_miracle]
	
	$Panel/MiracleName.text = "Selected Miracle: " + str(m.name)
	$Panel/MiracleDescription.text = str(m.description)
	$Panel/MiracleCost.text = "Cost in faith: " + str(int(m.cost))

	$Panel/Worshipers.text = "Worshipers: " + str(get_tree().get_nodes_in_group("Worshipers").size())
	$Panel/Nonbelievers.text = "Nonbelievers: " + str(get_tree().get_nodes_in_group("Nonbelievers").size())

	$Panel/Food.text = "Food: " + str(int(TheState.food))

	$Panel/Wariness.text = "Wariness: " + str(int(TheState.wariness * 100)) + "%"
