extends PopupMenu

const Options = {
	Clear = "Clear Selections",
	Exit = "Exit",
}

func _id_pressed(id: int) -> void:
	
	if get_item_text(id) == Options.Clear:
		
		for pnl in PanelFrame.panels_selection.duplicate():
			if pnl:
				pnl._on_select(false)
		PanelFrame.panels_selection.clear()
	elif get_item_text(id) == Options.Exit:
		get_tree().quit()
