extends CenterContainer

@export var path_button : Button
@export var path_label : Label

@export var save_button : Button

var path : String = 'Error'

var file_dialog : FileDialog
var _move_thread: Thread = null

func _ready() -> void:
	if path_button != null:
		path_button.pressed.connect(_on_file_button_pressed)
	if path_label != null:
		path_label.text = Settings.path
		path = Settings.path
	if save_button != null:
		save_button.pressed.connect(_on_save_button_pressed)

func _on_file_button_pressed() -> void:
	file_dialog = FileDialog.new()
	file_dialog.use_native_dialog = true
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.visible = true
	get_tree().current_scene.add_child(file_dialog)
	file_dialog.dir_selected.connect(_on_dir_selected)

func _on_dir_selected(dir: String) -> void:
	path_label.text = dir
	path = dir

func _on_save_button_pressed() -> void:
	if _move_thread and _move_thread.is_alive():
		print("Moving files...")
		return
		
	save_button.disabled = true
	if Settings.path != path:
		_move_thread = Thread.new()
		var task = _move_thread_worker.bind(Settings.path, path)
		_move_thread.start(task)

func _on_move_finished(success: bool, new_path: String) -> void:
	if _move_thread:
		_move_thread.wait_to_finish()
		_move_thread = null

	if success:
		Settings.path = new_path
		print("Wątek zakończył pracę: Folder 'engine' przeniesiony pomyślnie!")
		save_button.disabled = false
	else:
		print("Wątek zakończył pracę: Wystąpił błąd podczas przenoszenia plików.")

func _move_thread_worker(from_path: String, to_path: String) -> void:
	var success = move_engine_folder_recursive(from_path, to_path)
	_on_move_finished.call_deferred(success, to_path)
	
func move_engine_folder_recursive(from_path: String, to_path: String) -> bool:
	if from_path == to_path:
		return true
		
	var old_engine_path = from_path.path_join("engine")
	var new_engine_path = to_path.path_join("engine")
	
	if not DirAccess.dir_exists_absolute(old_engine_path):
		print("Brak folderu 'engine' w starej lokalizacji: ", old_engine_path)
		#_on_move_finished.call_deferred(true, new_engine_path)
		return false
		
	var success = copy_dir_recursive(old_engine_path, new_engine_path)
	
	if success:
		remove_dir_recursive(old_engine_path)
		return true
		
	return false

func copy_dir_recursive(from_dir: String, to_dir: String) -> bool:
	if not DirAccess.dir_exists_absolute(to_dir):
		var err = DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			return false

	var dir = DirAccess.open(from_dir)
	if not dir:
		return false

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var all_ok = true

	while file_name != "":
		if file_name != "." and file_name != "..":
			var source_path = from_dir.path_join(file_name)
			var target_path = to_dir.path_join(file_name)

			if dir.current_is_dir():
				if not copy_dir_recursive(source_path, target_path):
					all_ok = false
			else:
				var copy_err = DirAccess.copy_absolute(source_path, target_path)
				if copy_err != OK:
					print("Błąd kopiowania pliku: ", source_path, " Kod: ", copy_err)
					all_ok = false

		file_name = dir.get_next()
	dir.list_dir_end()
	return all_ok

func remove_dir_recursive(path_to_delete: String) -> void:
	var dir = DirAccess.open(path_to_delete)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			var current_path = path_to_delete.path_join(file_name)
			
			if dir.current_is_dir():
				remove_dir_recursive(current_path)
			else:
				DirAccess.remove_absolute(current_path)
				
		file_name = dir.get_next()
	dir.list_dir_end()
	
	DirAccess.remove_absolute(path_to_delete)
