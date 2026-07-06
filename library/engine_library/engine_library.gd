extends VBoxContainer

@export var download_engine_button : Button
@export var grid_container : GridContainer
const ENGINE_ITEM = preload("uid://chym1j5tsjp6q")

func _enter_tree() -> void:
	scan_for_engines()

func _ready() -> void:
	download_engine_button.pressed.connect(_on_button_button_down)
	SignalBusGlobal.download_finished.connect(_on_download_finished)

func _on_button_button_down() -> void:
	SignalBusGlobal.change_page_requested.emit(SiteContainer.VALID_PAGES.ENGINE_DOWNLOAD)

func _on_download_finished(output_path: String):
	print(output_path.get_file())
	add_specific_engine(output_path.get_file())
	sort_grid()

func scan_for_engines() -> void:
	if not grid_container:
		return
	for engine in EngineManager._get_avaible_engines():
		add_specific_engine(engine)
	
	sort_grid()

func sort_grid():
	var children = grid_container.get_children()
	
	children.sort_custom(EngineManager._is_version_lower)
	
	for i in range(children.size()):
		grid_container.move_child(children[i], i)

func add_specific_engine(engine: String) -> void:
	var split = engine.split('_')
	var version : String = ""
	var type : String = ""
	var net : bool = false

	match split.size():
		3:
			version = split[0]
			type = split[1]
			net = true
		2:
			version = split[0]
			type = split[1]
		1:
			version = split[0]
		_:
			return
	var engine_instatiated = ENGINE_ITEM.instantiate()
	engine_instatiated.version = version
	engine_instatiated.is_net = net
	engine_instatiated.type = type
	engine_instatiated.directory = SettingsManager.path.path_join('engine').path_join(engine)
	engine_instatiated.uninstall = delete_folder_and_contents
	grid_container.add_child(engine_instatiated)

func delete_folder_and_contents(path: String) -> Error:
	var dir = DirAccess.open(path)

	if not dir:
		return OK 
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_item_path = path.path_join(file_name)
			
			if dir.current_is_dir():
				var error = delete_folder_and_contents(full_item_path)
				if error != OK:
					return error
			else:
				var error = dir.remove(file_name)
				if error != OK:
					print("Failed to delete file: ", full_item_path)
					return error
					
		file_name = dir.get_next()
	
	dir.list_dir_end()

	var parent_dir = DirAccess.open(path.get_base_dir())
	if parent_dir:
		return parent_dir.remove(path.get_file())
	return FAILED
