extends PopupMenu


const Options = {
	Antialiasing = "Antialiasing",
	PlayAnim = "View Animations",
	Structure = "View Structure XML",
	Config = "View Configuration"
}

func _ready():
	for i in range(item_count):
		if get_item_text(i) == Options.Antialiasing:
			Config.ChangeConfiguration.connect(func (ConfigName:String, ConfigValue:Variant):
				if ConfigName == Options.Antialiasing:
					set_item_checked(i, ConfigValue)
				)

func _id_pressed(id: int) -> void:
	if get_item_text(id) == Options.Antialiasing:
		Config.Antialiasing = not Config.Antialiasing
		set_item_checked(id, Config.Antialiasing)
	elif get_item_text(id) == Options.PlayAnim:
		$PlayAnimation.Value.show()
	elif get_item_text(id) == Options.Structure:
		$Structure.Value.show()
	elif get_item_text(id) == Options.Config:
		$Configuration.Value.show()
