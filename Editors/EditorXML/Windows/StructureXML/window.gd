extends Window
class_name TreeCharacter

@export var ScaledSprite = 0.5
@export var minimunVectorEpic = Vector2(600, 600)
@onready var TreeValue : Tree = $Tree.Value
@onready var AttributeContainer : HBoxContainer = $AttributeContainer.Value
@onready var ResourceAttribute : Panel = $Attribute
@onready var SpriteUbication : Control = $SpriteUbication.Value
const _ItemTree = "ItemTree"
const _FlxSpr = "FlxSpr"
const _FlxAnim = "FlxAnim"
const canon = "canonico"


signal ChangeValue(Property: String, Value: Variant)


var Root: TreeItem
var SpriteSelect: FlxSprite

func callable_for_edit_mode(flxSprite: Node,V:bool=true):
	for child in AttributeContainer.get_children():
		if child:
			child.get_node("Box/Value").editable = V
			if flxSprite is FlxSprite:
				child.get_node("Box/Value").value = flxSprite[child.name]


func _ready() -> void:
	Config.ChangeConfiguration.connect(AutoScaling.CALLABLES.WINDOWSCALING.call(self))
	Root = TreeValue.create_item()
	Root.set_selectable(0, false)
	for attribute in FlxSprite.AttributesFrame:
		var dup = ResourceAttribute.duplicate()
		
		dup.name = attribute
		dup.visible = true
		dup.get_node("Box/Name").text = dup.name
		dup.get_node("IntValue").ChangeValue.connect(func (Value): ChangeValue.emit(attribute, Value))
		
		AttributeContainer.add_child(dup)
	
	

func _process(_delta:float) -> void:
	Root.set_text(0, Config.ConfigCharacter.CharacterName)
	for child in Root.get_children():
		if child.has_meta(_FlxSpr):
			var FlxSpr = child.get_meta(_FlxSpr)
			if FlxSpr:
				child.set_text(0, FlxSpr.name)
				
				if FlxSpr in FlxSprite.Sprites: continue
			
		
		if child.has_meta(_FlxAnim):
			var FlxAnim = child.get_meta(_FlxAnim)
			
			if (FlxAnim and FlxAnim is FlxAnimation):
				
				for childOfFlxAnim in child.get_children():
					if not childOfFlxAnim.has_meta(_FlxSpr): continue
					var FlxSpr = childOfFlxAnim.get_meta(_FlxSpr)
					
					if FlxSpr:
						if FlxSpr.animationOwner == FlxAnim: continue
						
						child.remove_child(childOfFlxAnim)
						Root.add_child(childOfFlxAnim)
					
					
					
				for Frame in FlxAnim.Frames:
					if Frame is PanelFrame:
						var FlxSpr : FlxSprite = Frame.get_node("FlxSprite").Value
						if not FlxSpr: continue
						if not FlxSpr.has_meta(_ItemTree): continue
						
						var ItemTreeFrame : TreeItem = FlxSpr.get_meta(_ItemTree) as TreeItem
						
						if not ItemTreeFrame: continue
						
						if ItemTreeFrame.get_parent() == child: continue
						if ItemTreeFrame.get_parent(): ItemTreeFrame.get_parent().remove_child(ItemTreeFrame)
						
						child.add_child(ItemTreeFrame)
					
				
				if FlxAnimation.Animations.has(FlxAnim.get_parent().name): continue
			
		
		Root.remove_child(child)
	
	for animation in FlxAnimation.Animations:
		
		var FlxAnim : FlxAnimation = FlxAnimation.Animations[animation]
		if not FlxAnim:
			FlxAnimation.Animations.erase(animation)
			continue
		if FlxAnim.has_meta(_ItemTree) and FlxAnim.get_meta(_ItemTree): continue
		
		
		var ItemTree = TreeValue.create_item(Root)
		ItemTree.set_text(0, animation)
		ItemTree.set_meta(_FlxAnim, FlxAnim)
		
		ItemTree.set_selectable(0, false)
		
		FlxAnim.set_meta(_ItemTree, ItemTree)
		
		FlxAnim.UpdateFrame.connect(func ():
			@warning_ignore("confusable_capture_reassignment")
			#var NewItemTree = FlxAnim.get_meta(_ItemTree)
			var before : TreeItem = null
			for frameOrden in FlxAnim.Frames:
				if not frameOrden.has_meta(_ItemTree): continue
				
				var ItemTreeFrame : TreeItem = frameOrden.get_meta(_ItemTree) as TreeItem
				
				if ItemTreeFrame:
					
					if before: ItemTreeFrame.move_before(before)
					before = ItemTreeFrame
				
				
			
			)
	
	var max_sized = Vector2.ZERO
	for FlxSpr in FlxSprite.Sprites:
		if not FlxSpr: continue
		max_sized.x = max(max_sized.x, FlxSpr.frameWidth)
		max_sized.y = max(max_sized.y, FlxSpr.frameHeight)
		
		var FlxAnim : FlxAnimation = FlxSpr.animationOwner
		var parentItem : TreeItem
		if FlxSpr.has_meta(_ItemTree) and FlxSpr.get_meta(_ItemTree): continue
		
		if FlxAnim and FlxAnim.has_meta(_ItemTree): parentItem = FlxAnim.get_meta(_ItemTree)
		
		var ItemTree = TreeValue.create_item(parentItem)
		ItemTree.set_text(0, FlxSpr.name)
		
		ItemTree.set_meta(_FlxSpr, FlxSpr)
		FlxSpr.set_meta(_ItemTree, ItemTree)
		
		FlxSpr.renamed.connect(func ():
			if ItemTree: ItemTree.set_text(0, FlxSpr.name)
			)
	FlxSprite.Sprites = FlxSprite.Sprites.filter(func(element): return element != null)
	
	if SpriteSelect:
		
		SpriteUbication.custom_minimum_size = SpriteSelect.get_full_size()
		SpriteUbication.custom_minimum_size *= 0.75
		SpriteUbication.custom_minimum_size *= ScaledSprite
		
		var calc = (minimunVectorEpic / max_sized)
		SpriteUbication.custom_minimum_size *= calc
		
		SpriteSelect.scale = Vector2.ONE * 0.75 * ScaledSprite * calc * SpriteSelect.get_full_size()/SpriteSelect.size
		








func MakeGhost():
	pass



func ItemSelect():
	var ItemTree: TreeItem = TreeValue.get_selected()
	
	if ItemTree.has_meta(_FlxSpr):
		
		if SpriteSelect:
			ChangeValue.disconnect(SpriteSelect.set)
			ChangeValue.disconnect(SpriteSelect.get_meta(canon).set)
			SpriteSelect.queue_free()
		
		
		var FlxSpr : FlxSprite = ItemTree.get_meta(_FlxSpr) as FlxSprite
		if not FlxSpr: return
		
		var dup : FlxSprite = FlxSpr.duplicate()
		dup.custom_sprite = false
		dup.set_meta(canon, FlxSpr)
		dup.scale = Vector2.ONE * 0.75 * ScaledSprite
		
		ChangeValue.connect(dup.set)
		ChangeValue.connect(FlxSpr.set)
		
		var newSize = Vector2(
			dup.get_full_width(),
			dup.get_full_height()
			) * 0.75 * ScaledSprite
		SpriteUbication.add_child(dup)
		SpriteUbication.custom_minimum_size = newSize
		SpriteSelect = dup
		
		callable_for_edit_mode(dup)
		
	
