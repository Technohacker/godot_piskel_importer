tool
extends EditorImportPlugin

func get_importer_name():
	return "com.technohacker.piskel"

func get_visible_name():
	return "Piskel Project"

func get_recognized_extensions():
	return ["piskel"]

# We save directly to stex because ImageTexture doesn't work for some reason
func get_save_extension():
	return "stex"

func get_resource_type():
	return "StreamTexture"

func get_import_options(preset):
	return []

func get_preset_count():
	return 0

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	"""
	Main import function. Reads the Piskel project and extracts the PNG image from it
	"""
	
	# Open the Piskel project file
	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
		printerr("Piskel Project file not found")
		return err

	# Parse it as JSON
	var text = file.get_as_text()
	var json = JSON.parse(text)

	if json.error != OK:
		printerr("JSON Parse Error")
		return json.error

	var project = json.result;

	# Make sure it's a JSON Object
	if typeof(project) != TYPE_DICTIONARY:
		printerr("Invalid Piskel project file")
		return ERR_FILE_UNRECOGNIZED;

	# For sanity, keep a version check
	if project.modelVersion != 2:
		printerr("Invalid Piskel project version")
		return ERR_FILE_UNRECOGNIZED;

	# Prepare an Image
	var final_image = null

	# Extract the first layer. It's encoded as an escaped JSON string
	for layer in project.piskel.layers:
		# Remove any escape backslashes
		layer = (layer as String).replace("\\", "")

		# Parse it
		layer = JSON.parse(layer)

		if layer.error != OK:
			return layer.error

		layer = layer.result

		# Get the base64 encoded image. It's always PNG (atleast in version 2 of the file)
		var dataURI = layer.chunks[0].base64PNG.split(",")
		var b64png = dataURI[dataURI.size() - 1]

		# Decode the PNG
		var png = Marshalls.base64_to_raw(b64png)

		# Parse the PNG from the buffer
		var img = Image.new()
		err = img.load_png_from_buffer(png)

		if err:
			return err

		if final_image == null:
			final_image = img
		else:
			final_image.blend_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), Vector2.ZERO)

	return save_stex(final_image, save_path)

# Taken from https://github.com/lifelike/godot-animator-import
func save_stex(image, save_path):
	var tmppng = "%s-tmp.png" % [save_path]
	image.save_png(tmppng)
	var pngf = File.new()
	pngf.open(tmppng, File.READ)
	var pnglen = pngf.get_len()
	var pngdata = pngf.get_buffer(pnglen)
	pngf.close()
	Directory.new().remove(tmppng)

	var stexf = File.new()
	stexf.open("%s.stex" % [save_path], File.WRITE)
	stexf.store_8(0x47) # G
	stexf.store_8(0x44) # D
	stexf.store_8(0x53) # S
	stexf.store_8(0x54) # T
	stexf.store_32(image.get_width())
	stexf.store_32(image.get_height())
	stexf.store_32(0) # flags: Disable all of it as we're dealing with pixel-perfect images
	stexf.store_32(0x07100000) # data format
	stexf.store_32(1) # nr mipmaps
	stexf.store_32(pnglen + 6)
	stexf.store_8(0x50) # P
	stexf.store_8(0x4e) # N
	stexf.store_8(0x47) # G
	stexf.store_8(0x20) # space
	stexf.store_buffer(pngdata)
	stexf.close()
