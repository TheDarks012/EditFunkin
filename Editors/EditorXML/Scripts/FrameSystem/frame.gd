extends Control
@onready var AddFrame : Button = $AddFrame.Value
@onready var ContainerFrames : GridContainer = $Container.Value
@onready var FramePreInstance : PackedScene = get_meta("PreInstance")
@onready var PlayAnimation : Window = $PlayAnimation.Value:
	set(value):
		PlayAnimation.get_frames = _getFrames

func _ready() -> void:
	
	ContainerFrames.child_order_changed.connect(func ():
		ContainerFrames.move_child(AddFrame, ContainerFrames.get_child_count()-1)
		, ConnectFlags.CONNECT_DEFERRED)
	
	GlobalCallables.AddFrame = _add
	GlobalCallables.GetFrames = _getFrames

func remove_id_animation(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int():
		i -= 1
		
	return animName.substr(0, i + 1)

func _add(Frame: FlxSprite, isXML: bool = false, animName:String = ""):
	var spriteName := "" if not Frame.has_meta("name") else str(Frame.get_meta("name"))
	
	var Inst : PanelFrame = FramePreInstance.instantiate()
	if Frame.get_parent(): Frame.get_parent().remove_child(Frame)
	Inst.add_child(Frame)
	Inst.move_child(Frame, 0)
	Frame.custom_minimum_size = Vector2(100, 100)
	
	if Inst.get_node("MoveClicker").tooltip_text.is_empty():
		Inst.get_node("MoveClicker").tooltip_text = Frame.name if not Frame.has_meta("name") else Frame.get_meta("name")
	
	var flxsprite = Inst.get_node("FlxSprite") as ObjectValue
	flxsprite.Value = Frame
	Inst.flxSprite = Frame
	#Frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if animName.is_empty(): animName = remove_id_animation(spriteName)
	
	Inst.OnRenamed()
	
	if isXML:
		var flxAnimation : FlxAnimation = null
		if not ContainerFrames.has_node(animName): 
			flxAnimation = FlxAnimation.new()
			var InstAnimation = FramePreInstance.instantiate()
			InstAnimation.add_child(flxAnimation)
			InstAnimation.name = animName
			flxAnimation.name = "FlxAnimation"
			InstAnimation.move_child(flxAnimation, 0)
			ContainerFrames.add_child(InstAnimation)
			GlobalSignals.AddAnimation.emit(animName, flxAnimation)
		else:
			flxAnimation = ContainerFrames.get_node(animName + "/FlxAnimation")
		
		var Name = animName + FlxSprite.animNameId(flxAnimation.Frames.size())
		
		Inst.name = Name
		Frame.name = Name
		
		flxAnimation.AddFrame.emit(Inst)
		GlobalSignals.UpdateAnimation.emit(animName, flxAnimation)
		
	else:
		ContainerFrames.add_child(Inst)

func _getFrames():
	var retn = []
	for child in ContainerFrames.get_children():
		if child == AddFrame: continue
		if child.has_node("FlxAnimation"):
			for frame in child.get_node("FlxAnimation").Frames:
				retn.append(frame)
			continue
		retn.append(child)
	return retn
