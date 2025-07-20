extends AcceptDialog

@onready var prefix : LineEdit = $prefix.Value
@onready var selection : LineEdit = $selection.Value
@onready var Box : VBoxContainer = $Box.Value
var typemode : String = "Prefix"

const TYPES = {
	prefix = "Prefix",
	selection = "Selection",
}
var SelectionsFrames = []
func _ready():
	GlobalSignals.OpenWindowName.connect(func (strName:String, data = {type = "Prefix"}):
		if strName == name:
			typemode = data.type
			
			for child in Box.get_children():
				child.hide()
			
			Box.get_node(typemode).show()
			
			SelectionsFrames = data.get("selects")
			
			show()
			data["node"] = self
		)

func create_keyframes(animName:String):
	var GettingFrames = GlobalCallables.GetFrames.call()
	if not GettingFrames : return
	
	for i in range(0, GettingFrames.size()):
		var frame: Panel = GettingFrames[i]
		if not frame: GettingFrames.remove_at(i); continue
		if frame.name.begins_with(animName):
			var Sprite = frame.get_node("FlxSprite").Value
			var Flx = Sprite
			
			
			GlobalCallables.AddFrame.call(Flx, true, animName)
			frame.queue_free()

func create_anim(animName:String, ArrayFrames:Array):
	
	for i in range(0, ArrayFrames.size()):
		var frame: PanelFrame = ArrayFrames[i]
		if not frame: ArrayFrames.remove_at(i); continue
		
		var Sprite = frame.get_node("FlxSprite").Value
		
		if not Sprite: continue
		frame._on_select(false)
		GlobalCallables.AddFrame.call(Sprite, true, animName)
		frame.queue_free()

func accept_create_keyframes():
	match typemode:
		TYPES.prefix:
			create_keyframes(prefix.text)
		TYPES.selection:
			create_anim(selection.text, SelectionsFrames)
