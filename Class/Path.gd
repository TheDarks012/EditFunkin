extends Resource
class_name Path

static func CheckIsExistFilename(this_path: String) -> bool:
	return FileAccess.file_exists(this_path)

static func GetPathFolder(this_path:String):
	var SplitterStr : PackedStringArray = this_path.split("/")
	var retn = this_path.substr(0, this_path.length()-SplitterStr[SplitterStr.size()-1].length())
	return retn

static func GetNameFile(this_path:String) -> String:
	if this_path.is_empty(): return ""
	
	return this_path.replace(GetPathFolder(this_path), "").replace(".png", "")

static func CheckIsImageFilename(this_path: String) -> bool:
	var image = Image.load_from_file(this_path)
	if image:
		image.call_deferred("free")
		return true
	return false
