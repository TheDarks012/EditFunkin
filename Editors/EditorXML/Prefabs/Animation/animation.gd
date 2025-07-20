extends Window

@onready var Grid = $Grid.Value as GridContainer

func AddPanelToGrid(child):
	Grid.add_child(child)
	
	var Size = Grid.get_child_count()
	if Size != 1:
		Size = ceil(sqrt(Size))
	Grid.columns = Size
	
	var offset = Vector2(
		Grid.get_theme_constant("h_separation"),
		Grid.get_theme_constant("v_separation")
	)
	
	
	size = (child.size + offset) * Size
