extends TextureRect
class_name FlxSprite
const CEROCOUNT = 4

signal Destroying()

@export var custom_sprite : bool = true:
	set(v):
		
		if v and self not in Sprites:
			Sprites.append(self)
		elif self in Sprites:
			Sprites.erase(self)
		custom_sprite = v

static var Sprites : Array[FlxSprite] = []


@export var x : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.region.position.x = v
		x = v
@export var y : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.region.position.y = v
		
		y = v
@export var width : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.region.size.x = v
		
		width = v
		frameWidth = frameWidth
@export var height : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.region.size.y = v
		
		height = v
		frameHeight = frameHeight

@export var frameWidth : int = 0:
	set(v):
		v = max(0, v)
		if texture is AtlasTexture:
			texture.margin.size.x = v - width
		
		frameWidth = v
@export var frameHeight : int = 0:
	set(v):
		v = max(0, v)
		if texture is AtlasTexture:
			texture.margin.size.y = v - height
		
		frameHeight = v
@export var frameX : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.margin.position.x = -v
		
		frameX = v
@export var frameY : int = 0:
	set(v):
		if texture is AtlasTexture:
			texture.margin.position.y = -v
		
		frameY = v

@export var animationOwner : FlxAnimation = null

var offset : Vector2 = Vector2()
var origin : Vector2 = Vector2()

var alpha = 1.0:
	set(value):
		value = clamp(value, 0, 1)
		self.self_modulate.a = value
		alpha = value
	get:
		return self.self_modulate.a

var antialiasing : bool = true

var color = Color():
	set(value):
		value.a = alpha
		self_modulate = value

func get_full_width() -> int: return max(width,frameWidth)
func get_full_height() -> int: return max(height,frameHeight)
func get_full_size() -> Vector2: return Vector2(get_full_width(), get_full_height())

func _init() -> void:
	if custom_sprite:
		Sprites.append(self)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	antialiasing = Config.Antialiasing



func _exit_tree() -> void: Destroying.emit()

func _process(_delta:float) -> void:
	if not Config.Antialiasing:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

const AttributesFrame = [
	"frameX",
	"frameY",
	"frameWidth",
	"frameHeight"
]

static func animNameId(num:int):
	var strnum = str(num)
	var rep = max(CEROCOUNT-strnum.length(), 0)
	return "0".repeat(rep) + strnum

static func CopyFrom(a:FlxSprite, b:FlxSprite):
	a.x = b.x
	a.y = b.y
	a.width = b.width
	a.height = b.height
	
	for property in AttributesFrame:
		a[property] = b[property]

static func create(X:int, Y:int, Width:int = 0, Height:int = 0):
	var this = FlxSprite.new()
	this.x = X
	this.y = Y
	this.width = Width
	this.height = Height
	this.frameWidth = Width
	this.frameHeight = Height
	
	
	this.texture = AtlasTexture.new()
	
	
	return this

static func CutterBordes(Flx: FlxSprite) -> Dictionary:
	var atlas : AtlasTexture = Flx.texture as AtlasTexture
	var image : Image = atlas.atlas.get_meta("Image") as Image
	var width_new = Flx.width
	var height_new = Flx.height
	
	var right:int
	var left:int=width_new
	var top:int
	var bottom:int=Flx.height
	
	var offset_new:=Vector2(Flx.x, Flx.y)
	
	for targetX:int in range(width_new): # starts in 0
		for targetY:int in range(height_new): # starts in 0
			if image.get_pixelv(Vector2(targetX, targetY) + offset_new).a > 0:
				if targetY > top: top = targetY
				if targetY < bottom: bottom = targetY
				if targetX > right: right = targetX
				if targetX < left: left = targetX
	
	width_new = right-left+1
	height_new = top-bottom+1
	
	var DictData = {
		x = offset_new.x+left,
		y = offset_new.y+bottom,
		width = width_new,
		height = height_new,
		frameX = Flx.frameX-left,
		frameY = Flx.frameY-bottom,
		frameWidth = max(Flx.width, Flx.frameWidth),
		frameHeight = max(Flx.height, Flx.frameHeight)
	}
	
	var callable_deferred = func ():
		if Flx:
			for property in DictData: if Flx.has_node_and_resource(":"+property): Flx.set(property, DictData[property])
	
	callable_deferred.call_deferred()
	
	return DictData


func loadGraphic(image: ImageTexture):
	if not texture or not texture is AtlasTexture: texture = AtlasTexture.new()
	texture = texture as AtlasTexture
	texture.atlas = image
