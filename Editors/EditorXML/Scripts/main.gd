extends Node

@onready var LoadFiles : FileDialog = $LoadFiles.Value
@onready var SaveFiles : FileDialog = $SaveFiles.Value
@onready var SaveFile : FileDialog = $SaveFile.Value
@onready var Frame : Control = $Frame.Value
@onready var GridFrames : GridContainer = $PanelAnimation/GridFrames.Value
@onready var Splitter : VSplitContainer = $Splitter.Value
var ArrayFrames : Array = []
var ArrayAnimation : Dictionary = {}


@onready var DataPathDefault = {
}
func _process(_delta: float) -> void:
	
	ArrayFrames = Frame._getFrames()

func _ready() -> void:
	
	
	
	GlobalSignals.AddAnimation.connect(func (animName:String, FlxAnim:FlxAnimation):
		if ArrayAnimation.has(animName): return false
		
		ArrayAnimation[animName] = FlxAnim
		return true
		)
	GlobalSignals.UpdateAnimation.connect(func (animName:String, FlxAnim:FlxAnimation):
		if not ArrayAnimation.has(animName): return false
		
		ArrayAnimation[animName] = FlxAnim
		return true
		)
	GlobalSignals.RemoveAnimation.connect(func (animName:String):
		if not ArrayAnimation.has(animName): return false
		
		ArrayAnimation.erase(animName)
		return true
		)
	
	GlobalSignals.AddPanelFrameToArrayFrame.connect(func (PanelFrameObj:PanelFrame):
		if PanelFrameObj not in ArrayFrames:
			ArrayFrames.append(PanelFrameObj)
		
		)
	GlobalSignals.ChangeGridFramesFor.connect(func (FlxAnim:FlxAnimation):
		const nameMeta = "AAccc"
		if has_meta(nameMeta):
			if get_meta(nameMeta).oldFlxAnim == FlxAnim: return
			
			GridFrames.child_order_changed.disconnect(get_meta(nameMeta).orden)
			GridFrames.child_entered_tree.disconnect(get_meta(nameMeta).add)
			GridFrames.child_exiting_tree.disconnect(get_meta(nameMeta).remove)
			
		
		if Splitter:
			Splitter.split_offset = -round(float(get_tree().get_root().size.y) / 2)
		
		var callable = func ():
			
			if not FlxAnim: return
			FlxAnim.Frames = GridFrames.get_children()
			FlxAnim.UpdateFrame.emit()
		
		var exittree = func ():
			if has_meta(nameMeta):
				GridFrames.child_order_changed.disconnect(get_meta(nameMeta).orden)
				GridFrames.child_entered_tree.disconnect(get_meta(nameMeta).add)
				GridFrames.child_exiting_tree.disconnect(get_meta(nameMeta).remove)
				remove_meta(nameMeta)

		var metadata = {
			orden = callable,
			add = FlxAnim.AddFrame.emit,
			remove = FlxAnim.RemoveFrame.emit,
			exit = exittree,
			oldFlxAnim = FlxAnim
		}
		for FrameNode in GridFrames.get_children():
			if not FrameNode: continue
			GridFrames.remove_child(FrameNode)
		
		for FrameNode in FlxAnim.Frames:
			FrameNode.set_meta("FlxAnimation", FlxAnim)
			GridFrames.add_child(FrameNode)
		
		GridFrames.child_entered_tree.connect(metadata.add)
		GridFrames.child_order_changed.connect(metadata.orden)
		GridFrames.child_exiting_tree.connect(metadata.remove)
		
		set_meta(nameMeta, metadata)
		)
	
	
	DataPathDefault[LoadFiles.name] = ""
	DataPathDefault[SaveFile.name] = ""
	DataPathDefault[SaveFiles.name] = ""
	var jsonLoad = FileAccess.open(StringTags.config.Path.DataPath, FileAccess.READ)
	var text = jsonLoad.get_as_text()
	jsonLoad.close()
	
	DataPathDefault = JSON.parse_string(text)
	
	LoadFiles.current_dir = DataPathDefault[LoadFiles.name]
	SaveFile.current_dir = DataPathDefault[SaveFile.name]
	
	SaveFiles.current_dir = DataPathDefault[SaveFiles.name]
	const DuplicateFrames = StringTags.file.export.DuplicateFrames
	SaveFiles.add_option(
		DuplicateFrames.Text,
		[DuplicateFrames.Values["true"], DuplicateFrames.Values["false"]], 
		0
	)


#region CreateFrames

func CreateFramesForXML(png:Image, xml: Dictionary):
	
	var SubTextures = xml.get("SubTextures")
	if not SubTextures: return
	
	for SubTexture in SubTextures:
		var Sprite = FlxSprite.create(
			int(SubTexture.x),
			int(SubTexture.y),
			int(SubTexture.width),
			int(SubTexture.height)
			)
		for property in SubTexture:
			if not Sprite.has_node_and_resource(":"+property): continue
			Sprite[property] = SubTexture[property]
		
		if not CachingSystem.ImagesTextures.has(png.resource_path):
			
			var NewImageTexture = ImageTexture.create_from_image(png) as ImageTexture 
			NewImageTexture.set_meta("Image", png)
			
			CachingSystem.ImagesTextures[png.resource_path] = NewImageTexture
			
		
		
		
		
		Sprite.loadGraphic(CachingSystem.ImagesTextures[png.resource_path])
		Frame._add(Sprite, true)
	
	return

func CreateFrame(png:Image):
	var Sprite : FlxSprite = FlxSprite.create(0, 0, png.get_size().x, png.get_size().y)
	
	if not CachingSystem.ImagesTextures.has(png.resource_path):
		var NewImageTexture = ImageTexture.create_from_image(png)
		CachingSystem.ImagesTextures[png.resource_path] = NewImageTexture
		NewImageTexture.set_meta("Image", png)
	
	Sprite.name = png.resource_path
	
	
	Sprite.loadGraphic(CachingSystem.ImagesTextures[png.resource_path])
	Frame._add(Sprite)
	return

#endregion

#region File

func ChangePath(Name: String, path_this:String):
	if not path_this.ends_with("/"): path_this += "/"
	
	DataPathDefault[Name] = path_this
	var jsonSave = FileAccess.open(StringTags.config.Path.DataPath, FileAccess.WRITE)
	var text = JSON.stringify(DataPathDefault)
	jsonSave.store_string(text)
	jsonSave.flush()
	
	jsonSave.close()


#region SaveFile

func sortRecti2(a, b):
	var regionA = a.Region as Rect2
	var regionB = b.Region as Rect2
	var size = {
		a = regionA.get_area(),
		b = regionB.get_area()
	}
	
	return size.a > size.b

func saveFile(dir : String = StringTags.config.Path.SaveFile): 
	var thread = Thread.new()
	var Loading : LoadingWindow = GuiGlobal.Loading
	Loading.show()
	var defaultText = Loading.TextName
	var progress = ["", 0.0]
	
	ChangePath(SaveFile.name, Path.GetPathFolder(dir))
	var Frames = Frame._getFrames() # devuelve los Panel que contiene los frames selecionados por el cliente
	
	var updatebar = func (TextName, Value):
		progress[0] = TextName
		progress[1] = Value
	
	
	var Atlas = {} # Contiene Datos y usa una Key especifica para evitar que se repita el mismo Frame
	thread.start(func ():
		for frame in Frames: # Agarra los frames en los distintos paneles que puso el cliente
			var sprite = frame.flxSprite as FlxSprite
			
			
			
			updatebar.call("Optimizado: "+sprite.name, 100 * 1.0/Frames.size())
			
			var atlas = sprite.texture as AtlasTexture
			var png = atlas.atlas.get_meta("Image")
			var region = Rect2i(atlas.region.position, Vector2(sprite.width, sprite.height))
			var key = {
				Region = region,
				png = png
			}
			
			if not Atlas.has(key):
				var DictData = FlxSprite.CutterBordes(sprite)
				region = Rect2i(
					DictData.x,
					DictData.y,
					DictData.width, 
					DictData.height,
					)
				Atlas[key] = {
					Sprite = [sprite],
					DictData = DictData,
					Frame = [frame],
					Region = region,
					Atlas = atlas
				}
			elif Atlas[key] is Dictionary:
				Atlas[key].Sprite.append(sprite)
				Atlas[key].Frame.append(frame)
		
		updatebar.call("Optimizacion terminada...", -100)
		
		
		#region orden las key de mayor a menor tamaño (area especificamente)
		var FramesOrden:Array = Atlas.keys()
		updatebar.call("Ordenado de mayor a menor tamaño...", 0)
		FramesOrden.sort_custom(sortRecti2)
		updatebar.call("Ordenado de mayor a menor tamaño...", 100)
		#endregion
		
		#*0.25*0.5
		var maxX: int = ceil(sqrt(FramesOrden.size())) # sirve para ordenar el spritesheet
		
		var current = Vector2(0, 0) # el la posicion que cree el algoritmo donde ira la siguiente image
		var maxHeightCurrent = 0
		updatebar.call("Creado image...", -100)
		var NewImage : Image = Image.create_empty(
			1, 1, false, Image.FORMAT_RGBA8
		) #imagen que se va a guardar
		updatebar.call("Creado image...", 100)
		var folder = dir.split("/")
		
		var metadata = []
		
		var nextY = false
		updatebar.call("Copiando...", -100)
		
		for i in range(0, FramesOrden.size()): # aqui basicamente se orden todo las imagenes en la imagen
		
			var Data : Dictionary = Atlas[FramesOrden[i]]
			
			var sizeImage = NewImage.get_size()
			var region = Data.Region as Rect2
			
			if not nextY: nextY = i % maxX == 0
			
			if nextY and current.x+region.size.x >= sizeImage.x:
				nextY = false
				current.x = 0
				current.y += maxHeightCurrent
				maxHeightCurrent = 0
			
			
			var atlas = Data.Atlas as AtlasTexture
			var spriteArray = Data.Sprite
			var png : Image = atlas.atlas.get_meta("Image") as Image # devuelve la Image que se uso para Crea el atlas del AtlasTexture
			var DictData = Data.DictData as Dictionary
			
			
			var newRegion = Rect2(
				current,
				region.size
			)
			
			
			
			
			for sprite in spriteArray:
				if not sprite is FlxSprite: continue
				updatebar.call("Copiando..." + sprite.name, 0)
				metadata.append(
					[
						StringTags.xml.SubTexture,
						{
							name = sprite.name,
							x = newRegion.position.x,
							width = DictData.width,
							y = newRegion.position.y,
							height = DictData.height,
							frameX = DictData.frameX,
							frameY = DictData.frameY,
							frameWidth = DictData.frameWidth,
							frameHeight = DictData.frameHeight,
						}
					]
				)
				updatebar.call("Copiando..." + sprite.name, (100 * 1.0/FramesOrden.size()) * 1.0/spriteArray.size())
			
			
			#region agranda la imagen si es necesario
			if current.x + region.size.x > sizeImage.x:
				NewImage.crop(current.x + region.size.x, sizeImage.y)
				sizeImage = NewImage.get_size()
			
			if current.y + region.size.y > sizeImage.y:
				NewImage.crop(sizeImage.x, current.y + region.size.y)
			
			#endregion
			if png.get_format() != Image.FORMAT_RGBA8:
				png.convert(Image.FORMAT_RGBA8)
			
			NewImage.blit_rect(png, region, newRegion.position)
			current.x = current.x + region.size.x
			maxHeightCurrent = max(maxHeightCurrent, region.size.y)
		
		metadata.sort_custom(func (a:Array, b:Array):
			var itemA : Dictionary = a[1]
			var itemB : Dictionary = b[1]
			var nameA : String = itemA.name
			var nameB : String = itemB.name
			return Sort.alfabetic(nameA, nameB)
			)
			
		metadata.insert(
			0,
			{imagePath = folder[folder.size()-1]}
			)
		updatebar.call("Creado XML...", -100)
		var xml = FileAccess.open(dir.substr(0, dir.length()-4)+".xml", FileAccess.WRITE)
		var text = XML.print_xml(metadata, StringTags.xml.TextureAtlas)
		xml.store_string(text)
		xml.flush()
		xml.close()
		updatebar.call("Listo!", 100)
		NewImage.save_png(dir)
		NewImage = null
		
		OS.delay_msec(250)
		
		, Thread.PRIORITY_HIGH)
	
	
	var progress_bar : ProgressBar = Loading.progressbar
	while thread.is_alive():
		Loading.TextName = progress[0]
		
		if progress[1]:
			progress_bar.value += progress[1]
			progress[1] = 0
		await get_tree().process_frame
	Loading.hide()
	progress_bar.value = progress_bar.min_value
	Loading.TextName = defaultText
	
	thread.wait_to_finish()
	
#endregion

#region SaveFiles
func saveFiles(dir : String = StringTags.config.Path.SaveFiles): 
	const Export = StringTags.file.export
	
	
	var Values = {
		DuplicateFrames = SaveFiles.get_selected_options()[Export.DuplicateFrames.Text]
	}
	
	var FramesCreates = {}
	if Values.DuplicateFrames == 0:
		FramesCreates = null
	
	ChangePath(SaveFiles.name, dir)
	var Frames = Frame._getFrames()
	
	for frame in Frames:
		var sprite = frame.get_node("FlxSprite").Value as FlxSprite
		var atlas = sprite.texture as AtlasTexture
		
		var region = Rect2i(atlas.region.position, Vector2i(sprite.width, sprite.height))
		
		if FramesCreates != null:
			var png = atlas.atlas.get_meta("Image")
			if not FramesCreates.has(png):
				FramesCreates[png] = {}
			
			if FramesCreates[png].has(region):
				continue
			FramesCreates[png][region] = true
		
		var image = Image.create(
			floor(sprite.frameWidth),
			floor(sprite.frameHeight),
			false,
			Image.FORMAT_RGBA8
			)
		image.blit_rect(atlas.atlas.get_image(), region, -Vector2i(sprite.frameX, sprite.frameY))
		image.save_png(dir + "/" + sprite.name + ".png")
#endregion

#region Load
func loadFiles(PathFiles: Array[String] = [StringTags.config.Path.LoadFiles]) -> void:
	var dir = PathFiles[0]
	var Images = {}
	
	GuiGlobal.AddTextToDebug(str(PathFiles))
	
	ChangePath(LoadFiles.name, Path.GetPathFolder(dir))
	
	for PathFile in PathFiles:
		if not PathFile.ends_with(".xml") and not PathFile.ends_with(".png"): continue
		
		var key = PathFile.substr(0, PathFile.length()-4)
		
		if not Images.has(key):
			Images[key] = {}
		
		
		if PathFile.ends_with(".xml"):
			Images[key]["xml"] = XML.Create(PathFile)
		elif PathFile.ends_with(".png"):
			
			if not CachingSystem.Images.has(PathFile):
				var newImage = Image.load_from_file(PathFile) as Image
				
				CachingSystem.Images[PathFile] = newImage
				
				newImage.resource_path = Path.GetNameFile(PathFile)
			
			Images[key]["png"] = CachingSystem.Images[PathFile]
	
	for key in Images:
		var imageData = Images.get(key)
		
		if not imageData.has("png"): continue
		if not imageData.has("xml"):
			CreateFrame(imageData.png)
			continue
		CreateFramesForXML(imageData.png, imageData.xml)
#endregion
#endregion
