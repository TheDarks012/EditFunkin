extends XMLParser
class_name XML


static func Create(path_this:String):
	var parser = XML.new()
	var err = parser.open(path_this)
	
	var TextureAtlas = null
	var SubTextures = []
	if err != OK:
		print("Error al abrir el archivo XML")
		return
	
	while parser.read() == OK:
		if parser.get_node_type() == NODE_ELEMENT:
			
			var Data = {
			}
			
			
			for i in range(parser.get_attribute_count()):
				
				Data[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
				
				
			if parser.get_node_name() == "TextureAtlas":
				TextureAtlas = Data
			if parser.get_node_name() == "SubTexture":
				
				GuiGlobal.AddTextToDebug(Data)
				SubTextures.append(Data)
		 
	return {TextureAtlas = TextureAtlas, SubTextures = SubTextures}



static func print_xml(data: Variant, root: String = "root") -> String:
	var xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
	var retn = conversion(data, 1)
	if retn.size() > 1:
		xml += "<%s%s>\n" % [root, retn[1]]
		xml += retn[0]
		xml += "</%s>" % root
	else:
		xml += "<%s>\n" % root
		xml += retn[0]
		xml += "</%s>" % root
	return xml

static func conversion(data: Variant, level: int = 1):
	var xml := ""
	var indetition = "\t".repeat(level)
	var mainxml = null
	
	for value in data:
		if value is Array:
			var Class = value[0]
			var item = null
			xml += indetition
			xml += "<" + Class
			if value.size() > 1:
				item = value[1]
			
			if item is Dictionary:
				
				for property in item:
					xml += " "
					xml += "%s=\"%s\"" % [property, escape_xml(str(item[property]))]
				xml += "/>\n"
		elif value is Dictionary:
			mainxml = ""
			for property in value:
				mainxml += " "
				mainxml += "%s=\"%s\"" % [property, escape_xml(str(value[property]))]
			
	return [xml, mainxml]

static func escape_xml(texto: String) -> String:
	return texto.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("'", "&apos;")
