extends CanvasLayer

func _process(delta):
	$Panel/Faith.text = "Faith: " + str(int(TheState.faith))
	
	var m = TheState.miracles[TheState.selected_miracle]
	
	$Panel/MiracleName.text = "Selected Miracle: " + str(m.name)
	$Panel/MiracleDescription.text = str(m.description)
	$Panel/MiracleCost.text = "Cost in faith: " + str(int(m.cost))
