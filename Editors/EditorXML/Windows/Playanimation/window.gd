extends Window


@onready var FlxAnimNode : FlxAnimation = $FlxAnimation.Value
@onready var AnimPopup : PopupMenu = $AnimationOptions.Value
var AnimPopupOrden = {}
var Frames := {}



func _ready() -> void:
	Config.ChangeConfiguration.connect(AutoScaling.CALLABLES.WINDOWSCALING.call(self))
	
	GlobalSignals.OpenWindowName.connect(func (strName:String,_type = null):
		if strName == name:
			show()
			return self
		)

	AnimPopup.id_pressed.connect(func (id):
		PlayAnimation(AnimPopup.get_item_text(id))
		)
	
	GlobalSignals.AddAnimation.connect(func (animName:String, FlxAnim:FlxAnimation):
		if Frames.has(animName): return false
		Frames[animName] = FlxAnim
		
		
		AnimPopup.add_item(animName)
		AnimPopupOrden[animName] = AnimPopup.get_child_count()
		
		return true
		)
	GlobalSignals.UpdateAnimation.connect(func (animName:String, FlxAnim:FlxAnimation):
		if not Frames.has(animName): return false
		
		Frames[animName] = FlxAnim
		
		
		return true
		)
	GlobalSignals.RemoveAnimation.connect(func (animName:String):
		if not Frames.has(animName): return false
		
		AnimPopup.remove_item(AnimPopupOrden[animName])
		
		Frames.erase(animName)
		return true
		)
	
	
	


func set_fps(new_text:String) -> void:
	FlxAnimNode.FPS = int(new_text)

func PlayAnimation(animName: String):
	FlxAnimNode.frame = 0
	if not Frames.has(animName): return
	if not Frames[animName]: return
	
	FlxAnimNode.Frames = Frames[animName].Frames
	FlxAnimNode._process(1.0/FlxAnimNode.FPS)


func _on_play_pressed() -> void:
	FlxAnimNode.frame = 0

func accept_remove_keyframes() -> void:
	pass
	#var prefix : String = Prefix_RemoveAnimation.text
	#remove_keyframes(prefix)
