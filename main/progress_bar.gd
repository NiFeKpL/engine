extends ProgressBar

@export var status_label: Label

func _ready() -> void:
	SignalBusGlobal.download_progress_update.connect(_on_progress_updated)
	SignalBusGlobal.download_finished.connect(_on_version_ready)
	SignalBusGlobal.download_error.connect(_on_download_error)
	SignalBusGlobal.queue_empty.connect(_on_all_done)
	SignalBusGlobal.unzip_progress_update.connect(_on_unzip_progress_updated)

func _on_unzip_progress_updated(current_file: int, total_files: int, file_name: String, target_folder: String, current_file_download_index: int, total_files_download: int) -> void:
	visible = true
	var percent = (float(current_file) / float(total_files)) * 100.0
	
	value = percent
	
	var nazwa_wersji = target_folder.get_file()
	status_label.text = "%d from %d, Unzip %s: %d/%d (%s)" % [
		current_file_download_index,
		total_files_download,
		nazwa_wersji, 
		current_file, 
		total_files, 
		file_name
	]
	
func _on_progress_updated(percent: float, downloaded_bytes: int, total_bytes: int, task_info: Dictionary) -> void:
	visible = true
	value = percent
	var nazwa_pliku = task_info["path"].get_file()
	var aktualny_nr = task_info.get("current_file_num", 1)
	var wszystkie_pliki = task_info.get("total_files_count", 1)
	status_label.text = "%d from %d, Downloading: %s (%.2f MB / %.2f MB)" % [
		aktualny_nr,
		wszystkie_pliki,
		nazwa_pliku, 
		float(downloaded_bytes) / 1024.0 / 1024.0, 
		float(total_bytes) / 1024.0 / 1024.0
	]

func _on_version_ready(_folder_path: String) -> void:
	status_label.text = ""
	
func _on_download_error(error_message: String, url: String) -> void:
	status_label.text = "Error: " + error_message
	print("Error with download: ", url)

func _on_all_done() -> void:
	visible = false
