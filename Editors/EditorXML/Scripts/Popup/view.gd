extends PopupMenu


enum Options {
	Antialiasing,
	Animations,
	PlayAnim,
	Structure,
	Config
}

func _ready():
	for i in range(item_count):
		if i == Options.Antialiasing:
			Config.ChangeConfiguration.connect(func (ConfigName:String, ConfigValue:Variant):
				if ConfigName == "Antialiasing":
					set_item_checked(i, ConfigValue)
				)

func _id_pressed(id: int) -> void:
	if id == Options.Antialiasing:
		Config.Antialiasing = not Config.Antialiasing
		set_item_checked(id, Config.Antialiasing)
	elif id == Options.PlayAnim:
		$PlayAnimation.Value.show()
	elif id == Options.Structure:
		$Structure.Value.show()
	elif id == Options.Config:
		$Configuration.Value.show()
