extends Node

class DownloadTask:
	var url: String
	var output_path: String
	
	func _init(_url: String, _output_path: String) -> void:
		self.url = _url
		self.output_path = _output_path

var download_queue : Array[DownloadTask]
var actual_download_task : DownloadTask
var is_downloading : bool = false
var is_unzip : bool = false
var total_tasks_in_queue : int = 0

@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	add_child(http_request)
	http_request.use_threads = true
	http_request.request_completed.connect(_on_request_completed)

func _process(_delta: float) -> void:
	if is_downloading and not is_unzip and actual_download_task != null:
		_check_progress()

func add_to_download(url: String, output_path: String) -> void:
	var new_download_task = DownloadTask.new(url, output_path)
	download_queue.append(new_download_task)
	
	total_tasks_in_queue += 1
	
	if not is_downloading and not is_unzip:
		download_next()

func download_next() -> void:
	if download_queue.is_empty():
		is_downloading = false
		is_unzip = false
		total_tasks_in_queue = 0
		actual_download_task = null
		SignalBusGlobal.queue_empty.emit.call_deferred()
		#print("All files downloaded.")
		return
	
	actual_download_task = download_queue.pop_front()
	is_downloading = true
	is_unzip = false # Resetujemy flagę unzippa przy nowym zadaniu
	
	var folder_path : String = actual_download_task.output_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(folder_path):
		var make_dir_err = DirAccess.make_dir_recursive_absolute(folder_path)
		if make_dir_err != OK:
			print("Can't create path! Code: ", make_dir_err)
	
	http_request.set_download_file(actual_download_task.output_path)
	
	var error = http_request.request(actual_download_task.url)
	if error != OK:
		SignalBusGlobal.download_error.emit("Can't connect to server: " + str(error), actual_download_task.url)
		download_next()

func _check_progress() -> void:
	var body_size = http_request.get_body_size()
	var downloaded = http_request.get_downloaded_bytes()
	
	if body_size > 0:
		var percent = (float(downloaded) / float(body_size)) * 100.0
		var current_file_number = total_tasks_in_queue - download_queue.size()
		var task = {
			"url": actual_download_task.url, 
			"path": actual_download_task.output_path,
			"current_file_num": current_file_number,
			"total_files_count": total_tasks_in_queue
		}
		SignalBusGlobal.download_progress_update.emit(percent, downloaded, body_size, task)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	http_request.set_download_file("")
	
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		#print('download finished')
		is_downloading = false
		is_unzip = true
		start_unzip_file(actual_download_task)
	else:
		SignalBusGlobal.download_error.emit("Błąd HTTP: " + str(response_code), actual_download_task.url)
		download_next()

func start_unzip_file(task: DownloadTask) -> void:
	var zip_path : String = task.output_path
	var exit_path : String = zip_path.get_basename()
	var current_file_number = total_tasks_in_queue - download_queue.size()
	var params = {
		"path_zip": zip_path,
		"folder_path": exit_path,
		"current_file_num": current_file_number,
		"total_files_count": total_tasks_in_queue
	}
	
	var _task_id = WorkerThreadPool.add_task(unzip_file.bind(params), true, "UNZIP_" + zip_path.get_file())
	#print("ID task: ", task_id)

func unzip_file(dane: Dictionary) -> void:
	var zip_path = dane.get("path_zip", "")
	var folder_path = dane.get("folder_path", "")
	var current_file_num = dane.get("current_file_num", "")
	var total_files_count = dane.get("total_files_count", "")
	#print("test",current_file_num,total_files_count)
	
	OS.delay_msec(50)
	
	var reader = ZIPReader.new()
	var err = reader.open(zip_path)
	if err != OK:
		print("Error with open ZIP. Code: ", err)
		SignalBusGlobal.download_error.emit.call_deferred("Error open zip: ", zip_path)
		_on_unzip_completed_main_thread.call_deferred()
		return
		
	var file_list = reader.get_files()
	var total_files : int = file_list.size()
	var current_file_index : int = 0 
	
	for file in file_list:
		current_file_index += 1
		var final_path = folder_path.path_join(file)
		
		SignalBusGlobal.unzip_progress_update.emit.call_deferred(
			current_file_index, 
			total_files,
			file.get_file(), 
			folder_path,
			current_file_num,
			total_files_count
		)
		
		if file.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(final_path)
			continue
			
		var next_folder = final_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(next_folder):
			DirAccess.make_dir_recursive_absolute(next_folder)
			
		var file_data = reader.read_file(file)
		if file_data.is_empty():
			continue
			
		var final_file = FileAccess.open(final_path, FileAccess.WRITE)
		if final_file:
			final_file.store_buffer(file_data)
			final_file.close()
			
	reader.close()
	
	delete_zip_file(zip_path)
	#print("UNZIP!")
	
	SignalBusGlobal.download_finished.emit.call_deferred(folder_path)
	
	_on_unzip_completed_main_thread.call_deferred()

func _on_unzip_completed_main_thread() -> void:
	is_unzip = false
	is_downloading = false
	download_next()

func delete_zip_file(path: String) -> void:
	if FileAccess.file_exists(path):
		var blad = DirAccess.remove_absolute(path)
		if blad == OK:
			#print("Delete finished: ", path)
			pass
		else:
			print("Error with deleting zip file: ", blad)
	else:
		print("File doesnt exist.")
