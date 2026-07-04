extends CenterContainer

@export var path_button : Button
@export var path_label : Label

@export var save_button : Button

var path : String = 'Error'

var file_dialog : FileDialog

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
	Settings.path = path
	pass
