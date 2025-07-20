extends Control
class_name AutoScaling

static var CALLABLES = {
	WINDOWSCALING = func (window: Window, sized: Vector2 = Vector2.ZERO):
		if not sized:
			sized = window.size
		return func (NameConfig, v):
			if NameConfig == "DisplayScale":
				window.size = sized / v
}:
	set(v):
		return







var data_scaling_old = {}

func scalingObject(obj:Control, Scale : float = 1, isSoloParent : bool = true):
	
	var array = [obj]
	if not isSoloParent:
		array = obj.get_children()
	
	for child in array:
		if data_scaling_old.has(child):
			child.scale /= data_scaling_old[child].scale
			child.size *= data_scaling_old[child].scale
		else: data_scaling_old[child] = {}
		data_scaling_old[child]["scale"] = Scale
		
		child.scale *= Scale
		child.size /= Scale


@export var Data: Array[Dictionary] = []



@export var fixMultPosition: Array[Control] = []



var Value = Config.DisplayScale:
	set(v):
		Value = v
		get_tree().get_root().content_scale_factor = v

func _ready() -> void:
	Config.ChangeConfiguration.connect(func (property, value):
		if property == "DisplayScale": Value = value
		)
