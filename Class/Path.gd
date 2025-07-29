extends Resource
class_name Path

static func CheckIsExistFilename(this_path: String) -> bool:
	return FileAccess.file_exists(this_path)

static func GetPathFolder(this_path:String, folderCount:int=0):
	var SplitterStr : PackedStringArray = this_path.split("/")
	var size = SplitterStr[SplitterStr.size()-1].length()
	
	var folderCount_abs = abs(folderCount)
	for i in range(0, folderCount_abs):
		i+=1
		i=i*folderCount/folderCount_abs
		
		size += SplitterStr[i-1].length() + 1
	
	var retn = this_path.substr(0, this_path.length()-size)
	return retn

static func GetNameFile(this_path:String, folderCount:int=0) -> String:
	if this_path.is_empty(): return ""
	
	return this_path.replace(GetPathFolder(this_path,folderCount), "").replace(".png", "")

static func CheckIsImageFilename(this_path: String) -> bool:
	var image = Image.load_from_file(this_path)
	if image:
		image=null;
		return true
	return false
