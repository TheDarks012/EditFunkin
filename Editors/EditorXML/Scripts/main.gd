extends Node

@onready var LoadFiles : FileDialog = $Windows/LoadFiles.Value
@onready var SaveFiles : FileDialog = $Windows/SaveFiles.Value
@onready var SaveFile : FileDialog = $Windows/SaveFile.Value
@onready var Frame : Control = $Frame.Value
@onready var GridFrames : GridContainer = $PanelAnimation/GridFrames.Value
@onready var Splitter : VSplitContainer = $Splitter.Value
@onready var DataPathDefault = {
}


var ArrayFrames : Array = []
var ArrayAnimation : Dictionary = {}

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
	GlobalSignals.ChangeGridFramesFor.connect(func (FlxAnim:FlxAnimation=null):
		const nameMeta = "AAccc"
		
		if has_meta(nameMeta):
			if get_meta(nameMeta).oldFlxAnim == FlxAnim: return
			
			GridFrames.child_order_changed.disconnect(get_meta(nameMeta).orden)
			GridFrames.child_entered_tree.disconnect(get_meta(nameMeta).add)
			GridFrames.child_exiting_tree.disconnect(get_meta(nameMeta).remove)
			remove_meta(nameMeta)
		
		
		for FrameNode in GridFrames.get_children():
			if not FrameNode: continue
			GridFrames.remove_child(FrameNode)
		
		
		if Splitter:
			Splitter.split_offset = 0
		
		if not FlxAnim: return
		
		if Splitter:
			Splitter.split_offset = min(-round(float(get_tree().get_root().size.y) / 2) / Config.DisplayScale, Splitter.split_offset)
		
		var callable = func ():
			if not FlxAnim: return
			FlxAnim.Frames = GridFrames.get_children()
			FlxAnim.UpdateFrame.emit()
		
		var exittree = func ():
			if has_meta(nameMeta):
				if get_meta(nameMeta).oldFlxAnim != FlxAnim: return
				GridFrames.child_order_changed.disconnect(get_meta(nameMeta).orden)
				GridFrames.child_entered_tree.disconnect(get_meta(nameMeta).add)
				GridFrames.child_exiting_tree.disconnect(get_meta(nameMeta).remove)
				remove_meta(nameMeta)
				GlobalSignals.ChangeGridFramesFor.emit()

		var metadata = {
			orden = callable,
			add = FlxAnim.AddFrame.emit,
			remove = FlxAnim.RemoveFrame.emit,
			exit = exittree,
			oldFlxAnim = FlxAnim
		}
		
		for FrameNode in FlxAnim.Frames:
			FrameNode.set_meta("FlxAnimation", FlxAnim)
			GridFrames.add_child(FrameNode)
		
		GridFrames.child_entered_tree.connect(metadata.add)
		GridFrames.child_order_changed.connect(metadata.orden)
		GridFrames.child_exiting_tree.connect(metadata.remove)
		FlxAnim.tree_exiting.connect(exittree, ConnectFlags.CONNECT_ONE_SHOT)
		
		set_meta(nameMeta, metadata)
		)
	
	
	DataPathDefault[LoadFiles.name] = StringTags.config.Path[LoadFiles.name]
	DataPathDefault[SaveFile.name] = StringTags.config.Path[SaveFile.name]
	DataPathDefault[SaveFiles.name] = StringTags.config.Path[SaveFiles.name]
	
	var jsonLoad = FileAccess.open(StringTags.config.Path.dir + StringTags.config.Path.DataPath, FileAccess.READ)
	
	if jsonLoad:
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
			if not Sprite.has_node_and_resource(":"+property) or property == "name": 
				Sprite.set_meta(property, SubTexture[property])
				continue
			Sprite[property] = SubTexture[property]
		
		if not CachingSystem.ImagesTextures.has(png.resource_path):
			
			var NewImageTexture = ImageTexture.create_from_image(png) as ImageTexture 
			NewImageTexture.set_meta("Image", png)
			
			CachingSystem.ImagesTextures[png.resource_path] = NewImageTexture
		
		Sprite.set_meta("name", SubTexture.name)
		
		Sprite.loadGraphic(CachingSystem.ImagesTextures[png.resource_path])
		Frame._add(Sprite, true)
	
	return

func CreateFrame(png:Image):
	var Sprite : FlxSprite = FlxSprite.create(0, 0, png.get_size().x, png.get_size().y)
	
	if not CachingSystem.ImagesTextures.has(png.resource_path):
		var NewImageTexture = ImageTexture.create_from_image(png)
		CachingSystem.ImagesTextures[png.resource_path] = NewImageTexture
		NewImageTexture.set_meta("Image", png)
	
	Sprite.set_meta("name", png.resource_name)
	
	
	Sprite.loadGraphic(CachingSystem.ImagesTextures[png.resource_path])
	Frame._add(Sprite)
	return

#endregion

#region File

func ChangePath(Name: String, path_this:String):
	if not path_this.ends_with("/"): path_this += "/"
	
	DataPathDefault[Name] = path_this
	
	var dir = DirAccess.open(StringTags.config.Path.dir)
	
	var dir_datapath = Path.GetPathFolder(StringTags.config.Path.DataPath)
	
	if dir.dir_exists(dir_datapath):
		dir.make_dir_recursive(dir_datapath)
	
	var jsonSave = FileAccess.open(StringTags.config.Path.dir + StringTags.config.Path.DataPath, FileAccess.WRITE)
	
	if jsonSave:
		var text = JSON.stringify(DataPathDefault, "\t")
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
	var progress = {
		text = "",
		porcent = 0.0
	}
	var Translations = StringTags.LoadingBar
	
	ChangePath(SaveFile.name, Path.GetPathFolder(dir))
	var Frames = Frame._getFrames() # devuelve los Panel que contiene los frames selecionados por el cliente
	
	
	var Atlas = {} # Contiene Datos y usa una Key especifica para evitar que se repita el mismo Frame
	thread.start(func ():
		for frame in Frames: # Agarra los frames en los distintos paneles que puso el cliente
			var sprite = frame.flxSprite as FlxSprite
			
			progress.text = Translations.trimming_edges % sprite.name
			
			
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
			
			progress.porcent = 100 * 1.0/Frames.size()
		
		progress.text = Translations.trimming_edges + ": " + Translations.done
		progress.porcent = -100
		
		
		#region orden las key de mayor a menor tamaño (area especificamente)
		var FramesOrden:Array = Atlas.keys()
		progress.text = Translations.tidy
		FramesOrden.sort_custom(sortRecti2)
		progress.porcent = 100
		#endregion
		
		var maxX: int = ceil(sqrt(FramesOrden.size())) # sirve para ordenar el spritesheet
		
		var current = Vector2.ONE * Config.Margin.extra_margin  #la posicion que cree el algoritmo donde ira la siguiente image
		
		var maxHeightCurrent = 0
		progress.text = Translations.creating_image
		progress.porcent = -100
		const FORMATIMAGE = Image.FORMAT_RGBA8
		var NewImage : Image = Image.create_empty(
			1, 1, false, FORMATIMAGE
		)
		progress.porcent = 100
		var folder = dir.split("/")
		
		var metadata = []
		
		var nextY = false
		progress.porcent = -100
		
		for i in range(0, FramesOrden.size()): # aqui basicamente se orden todo las imagenes en la imagen
			var Data : Dictionary = Atlas[FramesOrden[i]]
			var sizeImage = NewImage.get_size()
			var region = Data.Region as Rect2
			var atlas = Data.Atlas as AtlasTexture
			var spriteArray = Data.Sprite
			var png : Image = atlas.atlas.get_meta("Image") as Image # devuelve la Image que se uso para Crea el atlas del AtlasTexture
			var DictData = Data.DictData as Dictionary
			
			if not nextY: nextY = i % maxX == 0
			
			if nextY and current.x+DictData.width >= sizeImage.x:
				nextY = false
				current.x = Config.Margin.extra_margin
				current.y += maxHeightCurrent + Config.Margin.between_frames + (Config.Margin.extra_margin * 2)
				maxHeightCurrent = 0
			
			
			
			for sprite in spriteArray:
				if not sprite is FlxSprite: continue
				progress.text = Translations.writing_to_xml % sprite.name
				metadata.append(
					[
						StringTags.xml.SubTexture,
						{
							name = sprite.name,
							x = current.x,
							y = current.y,
							width = DictData.width,
							height = DictData.height,
							frameX = DictData.frameX,
							frameY = DictData.frameY,
							frameWidth = DictData.frameWidth,
							frameHeight = DictData.frameHeight,
						}
					]
				)
				progress.porcent = (100 * 1.0/FramesOrden.size()) * 1.0/spriteArray.size()
			
			
			#region agranda la imagen si es necesario
			if current.x + DictData.width > sizeImage.x:
				NewImage.crop(current.x + DictData.width + Config.Margin.extra_margin, sizeImage.y)
				sizeImage = NewImage.get_size()
			
			if current.y + DictData.height > sizeImage.y:
				NewImage.crop(sizeImage.x, current.y + DictData.height + Config.Margin.extra_margin)
				sizeImage = NewImage.get_size()
			
			#endregion
			
			if png.get_format() != FORMATIMAGE:
				png.convert(FORMATIMAGE)
			
			NewImage.blit_rect(png, region, current)
			current.x += DictData.width + Config.Margin.between_frames + Config.Margin.between_frames + (Config.Margin.extra_margin * 2)
			maxHeightCurrent = max(maxHeightCurrent, DictData.height)
		
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
		
		progress.text = Translations.saving % ": XML"
		
		var xml = FileAccess.open(dir.substr(0, dir.length()-4)+".xml", FileAccess.WRITE)
		var text = XML.print_xml(metadata, StringTags.xml.TextureAtlas)
		xml.store_string(text)
		xml.flush()
		xml.close()
		progress.text = Translations.saving % ": PNG"
		progress.porcent = 50
		NewImage.save_png(dir)
		NewImage = null
		
		progress.text = Translations.done
		progress.porcent = 50
		
		OS.delay_msec(250)
		
		, Thread.PRIORITY_HIGH)
	
	
	var progress_bar : ProgressBar = Loading.progressbar
	while thread.is_alive():
		Loading.TextName = progress.text
		
		if progress.porcent:
			progress_bar.value += progress.porcent
			progress.porcent = 0
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
		var png = atlas.atlas.get_meta("Image")
		
		var region = Rect2i(atlas.region.position, Vector2i(sprite.width, sprite.height))
		
		if FramesCreates != null:
			if not FramesCreates.has(png):
				FramesCreates[png] = {}
			
			if FramesCreates[png].has(region):
				continue
			FramesCreates[png][region] = true
		
		var image = Image.create(
			floor(sprite.frameWidth) + (Config.Margin.extra_margin * 2),
			floor(sprite.frameHeight) + (Config.Margin.extra_margin * 2),
			false,
			Image.FORMAT_RGBA8
			)
		image.blit_rect(png, region, -Vector2i(sprite.frameX, sprite.frameY) + (Vector2i.ONE * Config.Margin.extra_margin))
		image.save_png(dir + "/" + sprite.name + ".png")
#endregion

#region Load
func loadFiles(PathFiles: Array[String] = [StringTags.config.Path.LoadFiles]) -> void:
	
	var thread = Thread.new()
	var Loading : LoadingWindow = GuiGlobal.Loading
	var Translations = StringTags.LoadingBar
	Loading.show()
	var defaultText = Loading.TextName
	var progress = {
		text = "",
		porcent = 0.0
	}
	
	var dir = PathFiles[0]
	var Images : Dictionary[String, Array] = {}
	
	
	
	
	ChangePath(LoadFiles.name, Path.GetPathFolder(dir))
	thread.start(func ():
		for PathFile in PathFiles:
			progress.text = Translations.loading_path % PathFile
			
			var extension = PathFile.split(".")[-1].to_lower()
			
			if not "xml,png".contains(extension): continue
			
			var key = PathFile.substr(0, PathFile.length()-4)
			var data = {}
			
			if not Images.has(key):
				Images[key] = [data]
			else:
				if not Images[key][-1].has(extension):
					data = Images[key][-1]
				else:
					Images[key].append(data)
			
			if extension == "xml":
				data[extension] = XML.Create(PathFile)
			elif extension == "png":
				if not CachingSystem.Images.has(PathFile):
					var newImage = Image.load_from_file(PathFile) as Image
					
					CachingSystem.Images[PathFile] = newImage
					newImage.resource_path = PathFile
					
					newImage.resource_name = Path.GetNameFile(PathFile) \
						if \
							not Path.GetNameFile(PathFile)[0].is_valid_int() \
						else \
						Path.GetNameFile(PathFile, -1)
					
				data[extension] = CachingSystem.Images[PathFile]
			
			
			progress.porcent = 1.0/PathFiles.size() * 100
			
			
		for key in Images:
			var imageData = Images.get(key)
			for repit in imageData:
				if not repit.has("png"): continue
				if not repit.has("xml"):
					CreateFrame.call_deferred(repit.png)
					continue
				
				CreateFramesForXML.call_deferred(repit.png, repit.xml)
		
		)
	
	var progress_bar : ProgressBar = Loading.progressbar
	while thread.is_alive():
		Loading.TextName = progress.text
		
		if progress.porcent:
			progress_bar.value += progress.porcent
			progress.porcent = 0
		await get_tree().process_frame
	
	Loading.hide()
	progress_bar.value = progress_bar.min_value
	Loading.TextName = defaultText
	thread.wait_to_finish()
	
#endregion
#endregion


func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if event.is_action("ui_shift"):
			if event.is_pressed():
				PanelFrame.selection_multiple = true
			elif event.is_released():
				PanelFrame.selection_multiple = false
		elif event.is_action("ui_select_all"):
			if event.is_pressed():
				if PanelFrame.GridParent:
					for child in PanelFrame.GridParent.get_children():
						if not child: continue
						if child is PanelFrame:
							child._on_select(true)
		
	
