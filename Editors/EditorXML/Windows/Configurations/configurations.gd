extends Window

const DATA = {
	display_scale = {
		min = 1,
		max = 10
	},
	language = {
		es = "Español",
		en = "English"
	}
}

func _ready() -> void:
	Config.ChangeConfiguration.connect(AutoScaling.CALLABLES.WINDOWSCALING.call(self))

func _on_display_scale_ready() -> void:
	var display_scale : HBoxContainer = $gui/display_scale.Value
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


func _on_margin_between_frames_ready() -> void:
	var margin_between_frames = $frame/margin_between_frames.Value
	var Spin: SpinBox = margin_between_frames.get_node("SpinBox")
	if Spin:
		var callable = func(value:int):
			Config.Margin.between_frames = value
		
		Spin.value_changed.connect(callable)


func _on_extra_margin_ready() -> void:
	var extra_margin = $frame/extra_margin.Value
	var Spin: SpinBox = extra_margin.get_node("SpinBox")
	if Spin:
		var callable = func(value:int):
			Config.Margin.extra_margin = value
		
		Spin.value_changed.connect(callable)


func _on_antialiasing_ready() -> void:
	var antialiasing = $frame/antialiasing.Value
	var Check: CheckBox = antialiasing.get_node("CheckBox")
	
	if Check:
		Check.button_pressed = Config.Antialiasing
		
		Config.ChangeConfiguration.connect(func (ConfigName:String, ConfigValue:Variant):
			if ConfigName == "Antialiasing":
				Check.button_pressed = ConfigValue
			)
		
		var callable = func(value:bool):
			Config.Antialiasing = value
		
		Check.toggled.connect(callable)


func _on_language_ready() -> void:
	var language : HBoxContainer = $gui/language.Value
	var languages = TranslationServer.get_loaded_locales()
	
	var Menu: MenuButton = language.get_node("MenuButton")
	
	if Menu:
		var default_lan = TranslationServer.get_locale().split("_")[0]
		Menu.text = default_lan
		if DATA.language.has(default_lan):
			Menu.text = DATA.language[default_lan]
		
		var callables = []
		Menu.get_popup().id_pressed.connect(func (id):
			if callables.size() > id:
				callables[id].call()
		)
		for i in range(languages.size()):
			var lan = languages[i]
			Menu.get_popup().add_item(lan, i)
			if DATA.language.has(lan):
				Menu.get_popup().set_item_text(i, DATA.language[lan])
			
			
			callables.append(func ():
				TranslationServer.set_locale(lan)
				
				if DATA.language.has(lan):
					Menu.text = DATA.language[lan]
					return
				
				Menu.text = lan
				)
