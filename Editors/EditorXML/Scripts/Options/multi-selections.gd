extends HBoxContainer


func _on_toggled(toggled_on: bool) -> void:
	PanelFrame.selection_multiple = toggled_on

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if event.is_action("ui_shift"):
			if event.is_pressed():
				$CheckButton.button_pressed = true
			elif event.is_released():
				$CheckButton.button_pressed = false
	
