extends Panel
class_name PanelFrame

signal Destroying

@onready var flxSprite : FlxSprite = $FlxSprite.Value


var cursor_position := Vector2()
var Select = false;

var Frames : Array = []

static var panels_selection : Array[PanelFrame] = []


@onready var Name = $name.Value
@onready var placeholder = Control.new()

static var GridParent : GridContainer = null
static var DragPanelFrame : PanelFrame = null
static var selection_multiple : bool = false
static var last_from : PanelFrame = null


func onSelectionMoveFrame() -> void:
	if DragPanelFrame: return
	
	var pos = 0
	for i in range(get_parent().get_child_count()):
		if get_parent().get_child(i) == self:
			pos = i
	
	GridParent = get_parent()
	
	get_parent().add_child(placeholder)
	get_parent().move_child(placeholder, pos+1)
	
	self.reparent(GuiGlobal)
	DragPanelFrame = self
	Select = true;
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Destroying.emit()


func _on_select(toggled_on: bool, skipSelection : bool = false) -> void:
	
	if (not skipSelection and selection_multiple):
		
		if PanelFrame.panels_selection.size() > 0 and last_from:
			
			var from = last_from
			var to = self
			var childs = null
			if to != from:
				if from.get_parent() == to.get_parent():
					var common_parent : Node = from.get_parent()
					var inverse = false
					for i in range(common_parent.get_child_count()):
						var child = common_parent.get_child(i)
						if child == from or (child == to and childs == null):
							if child == to:
								var temp = from
								from = to
								to = temp
								inverse = true
							childs = []
						elif child == to:
							break
						elif childs != null:
							if not child: continue
							if not child is PanelFrame: continue
							childs.append(child)
					if inverse and childs:
						var lml = []
						var length = childs.size()
						for i in range(length):
							lml.append(childs[length-i-1])
						childs.clear()
						childs = lml
			if childs:
				for panel_frame:PanelFrame in childs:
					panel_frame._on_select(true, true)
	
	
	if toggled_on:
		if not selection_multiple or not last_from:
			last_from = self
		if self not in PanelFrame.panels_selection:
			PanelFrame.panels_selection.append(self)
	else:
		if self in PanelFrame.panels_selection:
			PanelFrame.panels_selection.erase(self)
		if last_from == self:
			last_from = null
			if not PanelFrame.panels_selection.is_empty():
				last_from = PanelFrame.panels_selection.back()
	
	$Check.set_pressed_no_signal.call_deferred(selection_multiple or toggled_on)


func MoveToCursor() -> void:
	
	var parent = GridParent as GridContainer
	Select = false;
	if parent and parent is GridContainer:
		cursor_position = parent.get_local_mouse_position()
		
		cursor_position.x = clamp(
			cursor_position.x,
			parent.global_position.x,
			parent.global_position.x + parent.size.x
		)
		
		var id = 0
		if parent == placeholder.get_parent():
			for i in range(parent.get_child_count()):
				if parent.get_child(i) == placeholder:
					id = i
			cursor_position -= placeholder.position
		
		cursor_position -= (size) * 0.5
		
		var scrollParent = parent.get_parent() as ScrollContainer
		if scrollParent:
			cursor_position.y += scrollParent.get_v_scroll_bar().value
		
		var margin = Vector2(
			parent.get_theme_constant("h_separation"),
			parent.get_theme_constant("v_separation")
		)
		
		var preVector = cursor_position / (size + margin)
		
		var moveVector = Vector2(
			round(preVector.x), 
			round(preVector.y)
			)
		
		id += moveVector.x + (moveVector.y * parent.columns)
		id = int(clamp(id, 0, parent.get_child_count()))
		placeholder.get_parent().remove_child(placeholder)
		
		self.reparent(parent)
		parent.move_child(
			self,
			id
		)
		DragPanelFrame = null

func ChangeFlxSprite(obj: Node) -> void:
	if not obj: return
	flxSprite = obj
	update_size(false)
	$OpenClicker.hide()
	OnRenamed()

func _ready() -> void:
	minimum_size_changed.connect(func ():
		placeholder.custom_minimum_size = custom_minimum_size
		)
	placeholder.custom_minimum_size = custom_minimum_size
	
	
	var callable = func (child:Node):
		if child is FlxSprite:
			var isAnim = child is FlxAnimation
			var callabletwo = update_size.bind(isAnim)
			child.resized.connect(callabletwo)
			
			child.tree_exiting.connect(func ():
				child.resized.disconnect(callabletwo)
				, ConnectFlags.CONNECT_ONE_SHOT)
	child_entered_tree.connect(callable)
	if not has_node("FlxAnimation"): return
	callable.call(get_node("FlxAnimation"))
	
	$Name.text = name


func update_size(isAnim:bool):
	var sl : Vector2 = size
	if isAnim and has_node("FlxAnimation"):
		var FlxAnim = get_node("FlxAnimation") as FlxAnimation
		var max_size := FlxAnimation.GetMaxPixel(get_node("FlxAnimation"))
		
		FlxAnim.size = max_size
		sl /= max_size
		FlxAnim.scale = Vector2.ONE * min(sl.x, sl.y)
	elif flxSprite:
		var flxSize = flxSprite.get_full_size()
		if flxSize > size:
			sl /= flxSize
			flxSprite.scale = Vector2.ONE * min(sl.x, sl.y)

func OpenWindow():
	var FlxAnim = $FlxAnimation as FlxAnimation
	
	GlobalSignals.ChangeGridFramesFor.emit(FlxAnim)

func _process(_delta:float):
	if Select:
		if Input.is_action_just_released("ui_click"):
			MoveToCursor()
		
		position = get_global_mouse_position() - size * 0.5

func OnRenamed():
	
	var strName : String = str(name)
	
	if flxSprite:
		if flxSprite.animationOwner:
			var length = strName.length()
			var finishedIdNumber = length
			for i in range(1, length):
				var y = length-i
				if strName[y].is_valid_int():
					finishedIdNumber = y
					continue
				break
			strName = strName.substr(finishedIdNumber, length)
		flxSprite.name = strName
	
	
	$Name.text = strName
	
	
