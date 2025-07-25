extends FlxAnimation

@export var parent_of_max_size:Control

var noLoop = false

func update_size():
	if noLoop: noLoop=false;return
	var max_size = Vector2.ZERO
	for FlxFrame:FlxSprite in FlxSprite.Sprites:
		if FlxFrame:
			if FlxFrame.animationOwner != self:
				max_size.x = max(FlxFrame.get_full_width(), max_size.x)
				max_size.y = max(FlxFrame.get_full_height(), max_size.y)
	
	max_size = Vector2.ONE * max(max_size.x, max_size.y)
	
	noLoop=true
	size = Vector2(get_full_width(), get_full_height())
	
	if parent_of_max_size:
		scale = parent_of_max_size.size / max_size
		position = Vector2.ZERO
	
	get_parent().custom_minimum_size = max_size * scale
	

func _ready():
	custom_sprite = false
	custom_animation = false
	super()
	
	resized.connect(update_size)
	StartAnimation.connect(update_size)
