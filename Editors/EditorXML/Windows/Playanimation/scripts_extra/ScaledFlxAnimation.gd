extends Control

@export var FlxAnim: FlxAnimation
var sized = Vector2.ONE

func _ready() -> void:
	resized.connect(func (): sized = size, ConnectFlags.CONNECT_ONE_SHOT)
	FlxAnim.set("position", Vector2.ZERO)
	#FlxAnim.StartAnimation.connect(startAnim, ConnectFlags.CONNECT_DEFERRED)
	FlxAnim.StartAnimation.connect(FlxAnim.set.bind("position", Vector2.ZERO), ConnectFlags.CONNECT_DEFERRED)


func _process(_delta: float) -> void:
	var max_size := Vector2.ZERO
	for FlxSpr in FlxSprite.Sprites:
		if FlxSpr:
			max_size.x = max(max_size.x, FlxSpr.get_full_width())
			max_size.y = max(max_size.y, FlxSpr.get_full_height())
	max_size = Vector2.ONE * min(max_size.x, max_size.y)
	
	scale = sized / max_size
	custom_minimum_size = size * scale
