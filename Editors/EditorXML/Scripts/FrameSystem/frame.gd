extends Control
@onready var AddFrame : Button = $AddFrame.Value
@onready var ContainerFrames : GridContainer = $Container.Value
@onready var FramePreInstance : PackedScene = get_meta("PreInstance")
@onready var PlayAnimation : Window = $PlayAnimation.Value:
	set(value):
		PlayAnimation.get_frames = _getFrames

func _ready() -> void:
	GlobalCallables.AddFrame = _add
	GlobalCallables.GetFrames = _getFrames

func remove_id_animation(animName: String) -> String:
	var i = animName.length() - 1
	while i >= 0 and animName[i].is_valid_int():
		i -= 1
	return animName.substr(0, i + 1)

func _add(Frame: FlxSprite, isXML: bool = false, animName:String = ""):
	
	var Inst = FramePreInstance.instantiate()
	if Frame.get_parent(): Frame.get_parent().remove_child(Frame)
	Inst.add_child(Frame)
	Inst.move_child(Frame, 0)
	Frame.custom_minimum_size = Vector2(100, 100)
	
	Inst.name = Frame.name
	Inst.flxSprite = Frame
	
	if Inst.get_node("MoveClicker").tooltip_text.is_empty():
		Inst.get_node("MoveClicker").tooltip_text = Frame.name
	
	var flxsprite = Inst.get_node("FlxSprite") as ObjectValue
	
	flxsprite.Value = Frame
	
	#Frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if animName.is_empty(): animName = remove_id_animation(Frame.name)
	
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
			GlobalSignals.UpdateAnimation.emit(animName, flxAnimation)
		
		var Name = animName + FlxSprite.animNameId(flxAnimation.Frames.size())
		
		Inst.name = Name
		Frame.name = Name
		
		flxAnimation.AddFrame.emit(Inst)
	else:
		ContainerFrames.add_child(Inst)
	
	
	
	ContainerFrames.move_child(AddFrame, ContainerFrames.get_child_count()-1)

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
