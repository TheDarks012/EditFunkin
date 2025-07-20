extends Button


func _process(_delta: float) -> void:
	disabled = not PanelFrame.panels_selection


func _on_pressed() -> void:
	for Frame in PanelFrame.panels_selection:
		if Frame:
			Frame.queue_free()
	PanelFrame.panels_selection.clear()
