extends Window

const DATA = {
	display_scale = {
		min = 1,
		max = 10
	}
}

func _ready() -> void:
	Config.ChangeConfiguration.connect(AutoScaling.CALLABLES.WINDOWSCALING.call(self))

func _on_display_scale_ready() -> void:
	var display_scale : HBoxContainer = $display_scale.Value
	var Menu: MenuButton = display_scale.get_node("MenuButton")
	if Menu:
		var callables = []
		Menu.get_popup().id_pressed.connect(func (id):
			if callables.size() > id:
				callables[id].call()
		)
		for i in range(DATA.display_scale.min, DATA.display_scale.max+1):
			var value : float = 0.25 * i
			var porcent : String = str(int(value * 100)) + "%"
			Menu.get_popup().add_item(porcent, i-1)
			
			callables.append(func ():
				
				Config.DisplayScale = value
				Menu.text = porcent
				)
