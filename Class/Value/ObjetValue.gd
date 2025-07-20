extends ClassValue
class_name ObjectValue
signal ChangeObject(obj: Node)
@export var Value: Node = null:
	set(v):
		Value = v
		ChangeObject.emit(v)
