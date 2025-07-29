extends Node
class_name StringTags

const config = {
	Path = {
		dir = "user://",
		DataPath = "Config/Saves/DataPath.json",
		SaveFiles = "",
		SaveFile = "",
		LoadFiles = ""
	},
	
}
const xml = {
	TextureAtlas = "TextureAtlas",
	SubTexture = "SubTexture",
	started = '<?xml version="1.0" encoding="UTF-8"?>\n',
	credits = "\t<!-- XML Created with EditFunkin: v%s -->\n\t<!-- https://thedarks012.itch.io/editfunkin -->\n"
}
const file = {
	export = {
		DuplicateFrames = {
			Text = "Crear Frames Repetidos:",
			Values = {
				"false" = "No",
				"true" = "Si"
			}
		}
	}
}



class LoadingBar:
	static func static_tr(message:StringName, context :StringName= &""):
		return TranslationServer.tr(message, context)
	
	static var loading_path = static_tr("loading_path")
	static var done = static_tr("done")
	static var trimming_edges = static_tr("trimming_edges")
	static var writing_to_xml = static_tr("writing_to_xml")
	static var creating_image = static_tr("creating_image")
	static var saving = static_tr("saving")
	static var tidy = static_tr("tidy")
	
