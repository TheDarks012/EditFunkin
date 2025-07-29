extends CodeEdit
var syntax :CodeHighlighter= syntax_highlighter

const data_highlight = {
	Color.RED : [
		"function",
		"end",
		"then",
		"do",
		"break",
		"if",
		"for",
		"in"
	]
}


func _ready():
	syntax.add_color_region("--", "", Color.DIM_GRAY, true)
	
	for color in data_highlight:
		for word in data_highlight[color]:
			syntax.add_keyword_color(word, color)
	
	set_code_completion_enabled(true)
	add_code_completion_option(CodeEdit.KIND_CLASS, "mi_funcion", "Mi función personalizada")
	
	
