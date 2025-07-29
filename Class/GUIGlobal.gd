extends CanvasLayer

var Loading : LoadingWindow = preload("res://Resources/Windows/loading/window.tscn").instantiate()
@onready var ListTextDebug := VBoxContainer.new()
@onready var control := Control.new()
func _ready() -> void:
	add_child(control)
	
	control.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	
	add_child(Loading)
	Loading.hide()
	
	control.add_child(ListTextDebug)
	ListTextDebug.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	
	


func AddTextToDebug(label:Variant):
	if not ListTextDebug:
		AddTextToDebug.call_deferred(label)
		return
	
	if not label is Label:
		label = str(label)
	
	if label is String:
		var text : String = label
		label = Label.new()
		label.text = text
	label = label as Label
	
	ListTextDebug.add_child(label)
	
	var back_text :String= label.text
	
	
	var max_label_num = round(control.size.y / label.get_minimum_size().y)
	var count = min(max_label_num,ListTextDebug.get_child_count())
	
	
	for i in range(ListTextDebug.get_child_count()):
		var child = ListTextDebug.get_child(i)
		var txt = child.text
		child.text = back_text
		back_text = txt
		
		if i > max_label_num:
			child.queue_free()
	
	
	
	
	var tween : Tween = create_tween()
	tween.tween_interval(2 + 0.25 * (max_label_num-count))
	
	var finished_callback = func ():
		if not label: return
		var tween2 = create_tween()
		tween2.tween_property(label, "modulate", Color("ffffff00"), 1)
		tween2.finished.connect(func ():
			label.queue_free()
			)
	
	
	tween.finished.connect(finished_callback)
	label.tree_exiting.connect(tween.stop, ConnectFlags.CONNECT_ONE_SHOT)
	label.tree_exiting.connect(func ():
		if tween.finished.is_connected(finished_callback):
			tween.finished.disconnect(finished_callback)
		, ConnectFlags.CONNECT_ONE_SHOT)
	
	
	return tween
