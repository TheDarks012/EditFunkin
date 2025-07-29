extends PopupMenu

enum Options {
	Files,
	ImpFrames,
	ExpFrames
}

@export var LoadFiles : FileDialog
@export var SaveFiles : FileDialog
@export var SaveFile : FileDialog

func _id_pressed(id: int) -> void:
	if id == Options.ImpFrames:
		LoadFiles.show()
	elif id == Options.ExpFrames:
		SaveFiles.show()
