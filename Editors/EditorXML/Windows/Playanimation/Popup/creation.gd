extends PopupMenu


const Options = {
	CreateAnimation = "Create Animation",
	RemoveAnimation = "Remove Animation"
}

@onready var MenuRemove : MenuButton = $RemoveAnimation/MenuButton.Value

func _id_pressed(id: int) -> void:
	if get_item_text(id) == Options.CreateAnimation:
		GlobalSignals.OpenWindowName.emit("CreateAnimation")
	#elif get_item_text(id) == Options.RemoveAnimation:
		#$RemoveAnimation.show()

func _ready() -> void:
	
	MenuRemove.get_popup().id_pressed.connect(func (id:int):
		MenuRemove.text = MenuRemove.get_popup().get_item_text(id)
		)
