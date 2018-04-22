extends CanvasLayer

func _process(delta):
	$Panel/Faith.text = "Faith: " + str(TheState.faith)