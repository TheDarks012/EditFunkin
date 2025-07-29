extends PopupMenu

enum Options {
	Selection,
	Clear,
	Other,
	Exit
}

func _id_pressed(id: int) -> void:
	
	if id == Options.Clear:
		
		for pnl in PanelFrame.panels_selection.duplicate():
			if pnl:
				pnl._on_select(false)
		PanelFrame.panels_selection.clear()
	elif id == Options.Exit:
		get_tree().quit()
