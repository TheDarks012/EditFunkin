extends Window
class_name LoadingWindow
@onready var cancelbutton : Button = $cancelbutton.Value
@onready var progressbar : ProgressBar = $progressbar.Value
@onready var label : Label = $label.Value

var EnabledCancel = true if not cancelbutton else cancelbutton.visible:
	set(v):
		EnabledCancel = v
		if not cancelbutton: return
		
		cancelbutton.visible = v
var TextName = "[*]" if not label else label.text:
	set(v):
		TextName = v
		
		if not label: return
		
		label.text = TextName


signal CancelButton(data:Dictionary)


func _ready():
	EnabledCancel = EnabledCancel
	if cancelbutton:
		cancelbutton = cancelbutton as Button
		cancelbutton.pressed.connect(_cancel)

func _cancel():
	if not EnabledCancel: return
	var data = {isCancel = false}
	CancelButton.emit(data)
	
	if not data.isCancel: return 
	
	hide()
