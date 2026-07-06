class_name SignalBus extends Node

@warning_ignore("unused_signal")
signal change_page_requested(page: SiteContainer.VALID_PAGES)


#download manager
@warning_ignore("unused_signal")
signal download_progress_update(percent: float, download_bytes: int, total_bytes: int, active_task: Dictionary)
@warning_ignore("unused_signal")
signal download_finished(output_path: String)
@warning_ignore("unused_signal")
signal download_error(error_message: String, url: String)
@warning_ignore("unused_signal")
signal queue_empty()
@warning_ignore("unused_signal")
signal unzip_progress_update(current_file: int, total_files: int, file_name: String, target_folder: String, current_file_download_index: int, total_files_download: int)

@warning_ignore("unused_signal")
signal engine_uninstalled(path: String)

#@warning_ignore("unused_signal")
#signal default_engine_changed(version: String)
