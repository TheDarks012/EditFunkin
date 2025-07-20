extends Node
signal ChangeConfiguration(string:String, value:Variant)
var Antialiasing : bool = true:
	set(v): ChangeConfiguration.emit("Antialiasing", v); Antialiasing = v
var DisplayScale : float = 1:
	set(v): ChangeConfiguration.emit("DisplayScale", v); DisplayScale = v


class ConfigCharacterClass:
	
	var CharacterName : String = "BF"
	var Animations : Dictionary[String, FlxAnimation] = {}:
		get:
			return FlxAnimation.Animations
		set(v):
			FlxAnimation.Animations = v

class AndroidActions:
	static var permissions : PackedStringArray = [
		"android.permission.READ_MEDIA_VISUAL_USER_SELECTED",
		"android.permission.READ_EXTERNAL_STORAGE",
		"android.permission.WRITE_EXTERNAL_STORAGE"
	]
	static func request_permissions():
		OS.request_permissions()

var ConfigCharacter : ConfigCharacterClass = ConfigCharacterClass.new()


func _ready():
	var osName = OS.get_name()
	if osName == "Android":
		AndroidActions.request_permissions()
