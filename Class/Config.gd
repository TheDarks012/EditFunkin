extends Node
signal ChangeConfiguration(string:String, value:Variant)
var Antialiasing : bool = true:
	set(v): ChangeConfiguration.emit("Antialiasing", v); Antialiasing = v
var DisplayScale : float = 1:
	set(v): ChangeConfiguration.emit("DisplayScale", v); DisplayScale = v

class Margin:
	static var between_frames := 0
	static var extra_margin := 0

class ConfigCharacterClass:
	
	var CharacterName : String = "BF"
	var Animations : Dictionary[String, FlxAnimation] = {}:
		get:
			return FlxAnimation.Animations
		set(v):
			FlxAnimation.Animations = v


var ConfigCharacter : ConfigCharacterClass = ConfigCharacterClass.new()


func _ready():
	var osName = OS.get_name()
	if osName == "Android":
		OS.request_permissions()
