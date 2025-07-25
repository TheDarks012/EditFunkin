extends Window


@onready var FlxAnimNode : FlxAnimation = $FlxAnimation.Value
@onready var AnimPopup : PopupMenu = $AnimationOptions.Value
var AnimPopupOrden = {}



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
	
	GlobalSignals.AddAnimation.connect(func (animName:String, _FlxAnim:FlxAnimation):
		AnimPopupOrden[animName] = AnimPopup.item_count
		AnimPopup.add_item(animName)
		return true
		)
	GlobalSignals.RemoveAnimation.connect(func (animName:String):
		AnimPopup.remove_item(AnimPopupOrden[animName])
		for ordenName in AnimPopupOrden:
			if AnimPopupOrden[ordenName] > AnimPopupOrden[animName]:
				AnimPopupOrden[ordenName]-=1;
		
		AnimPopupOrden.erase(animName)
		return true
		)
	
	
	


func set_fps(new_text:String) -> void:
	FlxAnimNode.FPS = int(new_text)

func PlayAnimation(animName: String):
	FlxAnimNode.frame = 0
	if not FlxAnimation.Animations.has(animName): return
	var anim = FlxAnimation.Animations[animName]
	if not anim: return
	
	FlxAnimNode.Frames = anim.Frames
	FlxAnimNode._process(1.0/FlxAnimNode.FPS * 2)


func _on_play_pressed() -> void:
	FlxAnimNode.frame = 0

func accept_remove_keyframes() -> void:
	pass
	#var prefix : String = Prefix_RemoveAnimation.text
	#remove_keyframes(prefix)
