extends ClassValue
class_name IntValue
signal ChangeValue(Value:int)
@export var Value: int = 0:
	set(v):
		Value = v
		ChangeValue.emit(v)
