extends Button


func _process(_delta: float) -> void:
	
	var select : Array[PanelFrame] = []
	for frame in PanelFrame.panels_selection:
		if not frame: continue
		if not frame.flxSprite: continue
		if not frame.has_node("FlxAnimation") and not frame.flxSprite.animationOwner:
			select.append(frame)
			break
	
	disabled = not select
	


func _on_pressed() -> void:
	var select : Array[PanelFrame] = []
	for frame in PanelFrame.panels_selection:
		if not frame.has_node("FlxAnimation"):
			select.append(frame)
	var Data = {
		selects = select,
		type = "Selection"
	}
	GlobalSignals.OpenWindowName.emit("CreateAnimation", Data)
