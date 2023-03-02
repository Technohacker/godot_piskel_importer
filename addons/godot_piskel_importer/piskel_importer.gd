@tool
extends EditorImportPlugin

func _get_importer_name():
	return "com.technohacker.piskel"

func _get_visible_name():
	return "Piskel Project"

func _get_recognized_extensions():
	return ["piskel"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "ImageTexture"

func _get_import_options(path, preset_index):
	return []

func _get_priority():
	return 1.0

func _get_import_order():
	return 0

func _get_preset_count():
	return 0

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	"""
	Main import function. Reads the Piskel project and extracts the PNG image from it
	"""
	
	# Open the Piskel project file
	var file = FileAccess.open(source_file, FileAccess.READ)
	var err = FileAccess.get_open_error()
	if err != OK:
		printerr("Piskel Project file not found")
		return err
	
	# Parse it as JSON
	var text = file.get_as_text()
	var json = JSON.new()
	var err2 = json.parse(text)
	if err2 != OK:
		printerr("JSON parse error")
		return json.get_error_message()

	var project = json.data;
	
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
		layer = JSON.parse_string(layer)
		
		if layer == null:
			printerr("Layer parse error")
			return ERR_FILE_CORRUPT

		# Get the base64 encoded image. It's always PNG (atleast in version 2 of the file)
		var dataURI = layer.chunks[0].base64PNG.split(",")
		var b64png = dataURI[dataURI.size() - 1]
		
		# Decode the PNG
		var png = Marshalls.base64_to_raw(b64png)

		# Parse the PNG from the buffer
		var img = Image.new()
		err = img.load_png_from_buffer(png)

		if err:
			printerr("Load png from buffer error")
			return err

		if final_image == null:
			final_image = img
		else:
			final_image.blend_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), Vector2.ZERO)
	
	var texture = ImageTexture.create_from_image(final_image)
	return ResourceSaver.save(texture, "%s.%s" % [save_path, _get_save_extension()])
