extends PopupMenu

const Options = {
	ImpFrames = "Import Frames",
	ExpFrames = "Export Frames",
}

@onready var LoadFiles : FileDialog = get_tree().current_scene.get_node("LoadFiles").Value
@onready var SaveFiles : FileDialog = get_tree().current_scene.get_node("SaveFiles").Value
@onready var SaveFile : FileDialog = get_tree().current_scene.get_node("SaveFile").Value

func _id_pressed(id: int) -> void:
	
	if get_item_text(id) == Options.ImpFrames:
		LoadFiles.show()
	elif get_item_text(id) == Options.ExpFrames:
		SaveFiles.show()
