extends Control

# Configuración exportable para fácil ajuste en el editor
@export var area_size: Vector2 = Vector2(800, 600)  # Tamaño del área a mosaiquear
@export var tile_size: Vector2 = Vector2(100, 100)  # Tamaño base del mosaico
@export var random_variation: float = 0.3  # Variación aleatoria en tamaño (0 para mosaicos perfectos)
@export var color_variation: float = 0.2  # Variación de color
@export var draw_outlines: bool = true  # Dibujar bordes de los mosaicos

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	generate_tiling()

func generate_tiling():
	# Limpiar mosaicos anteriores (si los hay)
	for child in get_children():
		child.queue_free()
	
	# Generar mosaicos
	var x = 0
	while x < area_size.x:
		var y = 0
		while y < area_size.y:
			# Calcular tamaño del mosaico actual con posible variación
			var current_tile_width = tile_size.x * (1 + rng.randf_range(-random_variation, random_variation))
			var current_tile_height = tile_size.y * (1 + rng.randf_range(-random_variation, random_variation))
			
			# Asegurarse de no salirnos del área
			if x + current_tile_width > area_size.x:
				current_tile_width = area_size.x - x
			if y + current_tile_height > area_size.y:
				current_tile_height = area_size.y - y
			
			# Crear el mosaico
			create_tile(x, y, current_tile_width, current_tile_height)
			
			y += current_tile_height
		x += tile_size.x  # Usamos el tamaño base para el paso en X para mejor distribución

func create_tile(x: float, y: float, width: float, height: float):
	var tile = ColorRect.new()
	tile.position = Vector2(x, y)
	tile.size = Vector2(width, height)
	
	# Color aleatorio con variación
	var base_color = Color(rng.randf(), rng.randf(), rng.randf())
	var color_variation = Color(
		base_color.r * rng.randf_range(1 - color_variation, 1 + color_variation),
		base_color.g * rng.randf_range(1 - color_variation, 1 + color_variation),
		base_color.b * rng.randf_range(1 - color_variation, 1 + color_variation)
	)
	tile.color = color_variation
	
	# Opcional: añadir borde
	if draw_outlines:
		var outline = Line2D.new()
		outline.points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(width, 0),
			Vector2(width, height),
			Vector2(0, height),
			Vector2(0, 0)
		])
		outline.width = 2
		outline.default_color = Color(0, 0, 0, 0.5)
		tile.add_child(outline)
	
	add_child(tile)

# Para regenerar con nuevos parámetros
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		generate_tiling()
