extends FlxSprite
class_name FlxAnimation
static var InstanceWindow = preload("res://Editors/EditorXML/Prefabs/Animation/Animation.tscn")


@export var custom_animation : bool = true:
	set(v):
		custom_sprite = v
		custom_animation = v
static var Animations : Dictionary[String, FlxAnimation] = {}

signal AddFrame(Frame)
signal RemoveFrame(Frame)
signal UpdateFrame

signal FinishedAnimation
signal StartAnimation

var Frames : Array[Node] = []
var FPS : int = 24
var frame : int = 0

func _ready() -> void:
	if custom_animation:
		var last_name = get_parent().name
		Animations[last_name] = self
		get_parent().renamed.connect(func ():
			if Animations.has(last_name): return
			
			Animations[get_parent().name] = Animations[last_name]
			Animations.erase(last_name)
			@warning_ignore("confusable_capture_reassignment")
			last_name = get_parent().name
			)
	
	AddFrame.connect(func (Frame):
		Frames.append(Frame)
		if Frame.has_node("FlxSprite"):
			var Flx : FlxSprite = Frame.get_node("FlxSprite").Value
			if Flx:
				Flx.animationOwner = self
		UpdateFrame.emit()
		)
	
	UpdateFrame.connect(func ():
		for i in range(0, Frames.size()):
			
			var Frame = Frames[i]
			if not Frame is PanelFrame: continue
			
			
			var newName = str(get_parent().name) + FlxSprite.animNameId(i)
			
			if Frame.get_parent():
				if Frame.get_parent().has_node(newName):
					Frame.get_parent().get_node(newName).name = str(Frame.get_parent().get_node(newName).get_instance_id())
			Frame.set_meta("name", newName)
			Frame.name = newName
			
			Frame.OnRenamed()
			
			var Flx = Frame.get_node("FlxSprite").Value
			
			if Flx:
				Flx.name = newName
			
			
		)
	
	RemoveFrame.connect(func (Frame):
		Frames.erase(Frame)
		UpdateFrame.emit()
		if not Frame.has_node("FlxSprite"): return
		var Flx : FlxSprite = Frame.get_node("FlxSprite").Value
		if Flx:
			Flx.animationOwner = null
		
		Frame.name = Frame.get_node("MoveClicker").tooltip_text
		)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var framesfrees : Array[Node] = Frames.duplicate()
		if custom_animation:
			GlobalSignals.RemoveAnimation.emit(get_parent().name)
		while framesfrees.size() > 0:
			var panelFrame = framesfrees[0]
			if panelFrame:
				var flxSpr = panelFrame.flxSprite
				if flxSpr:
					FlxSprite.Sprites.erase(flxSpr)
			framesfrees.remove_at(0)
			
		

static func GetMaxPixel(FlxAnim:FlxAnimation) -> Vector2:
	var max_size := Vector2.ZERO
	for FlxSpr in FlxAnim.GetFramesInFlxSprites():
		max_size.x = max(FlxSpr.get_full_width(), max_size.x)
		max_size.y = max(FlxSpr.get_full_height(), max_size.y)
	return max_size


func GetFramesInFlxSprites() -> Array[FlxSprite]:
	var retn : Array[FlxSprite] = []
	for FlxPanel in Frames:
		if not FlxPanel or not FlxPanel is PanelFrame: continue
		var flxValue = FlxPanel.get_node("FlxSprite")
		if not flxValue or not flxValue is ObjectValue: continue
		var FlxSpr = flxValue.Value
		if not FlxSpr or not FlxSpr is FlxSprite: continue
		
		retn.append(FlxSpr)
	return retn


var timeElapsed = 0


func _process(delta: float) -> void:
	super(delta)
	
	if Frames.size() <= 0: return
	var update_frame = func ():
		frame += 1
		if frame >= Frames.size():
			frame = 1
			FinishedAnimation.emit()
	
	
	timeElapsed += delta
	if timeElapsed >= 1.0/FPS:
		timeElapsed = 0
		if frame <= 0:
			StartAnimation.emit()
		
		if not Frames[frame]:
			return update_frame.call()
		if not Frames[frame] is PanelFrame: 
			return update_frame.call()
		var Frame = Frames[frame].flxSprite
		if not Frame: return update_frame.call()
		texture = Frame.texture
		update_frame.call()
