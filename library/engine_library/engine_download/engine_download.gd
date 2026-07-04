extends CenterContainer

var http_request : HTTPRequest
var details_request : HTTPRequest

var actual_versions : Array
var actual_details : Array
var actual_download : Dictionary

@export var VersionTypeContainer : HBoxContainer
@export var ButtonsContainer : HBoxContainer

@export var details_label: Label
@export var type_button : Button
@export var version_option_button : OptionButton
@export var net_include : OptionButton

@export var download_button : Button

@export var Loading : Label


var is_nightly : bool = false

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	details_request = HTTPRequest.new()
	add_child(details_request)
	
	http_request.request_completed.connect(_on_request_completed)
	details_request.request_completed.connect(_on_details_request_completed)
	type_button.toggled.connect(_on_button_toggled)
	
	version_option_button.item_selected.connect(_on_version_selected)
	net_include.item_selected.connect(_on_net_selected)
	type_button.button_pressed = true
	
	download_button.pressed.connect(_on_download_button_pressed)
	
	version_option_button.get_popup().max_size.y = 300

func _process(_delta: float) -> void:
	if Loading.visible == true:
		@warning_ignore("integer_division")
		var count : int = (Time.get_ticks_msec() / 500) % 4
		Loading.text = "Loading" + ".".repeat(count)

func _on_button_toggled(toggled_on: bool) -> void:
	is_nightly = not toggled_on
	update_versions()

func update_versions() -> void:
	VersionTypeContainer.hide()
	ButtonsContainer.hide()
	Loading.show()
	
	version_option_button.clear()
	if is_nightly:
		var error = http_request.request("https://blazium.app/api/versions/data/nightly")
		if error != OK:
			print('Something gone wrong')
	else:
		var error = http_request.request("https://blazium.app/api/versions/data/release")
		if error != OK:
			print('Something gone wrong')

func _on_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	actual_versions = response
	
	for id in range(actual_versions.size()):
		var version = actual_versions[id]
		version_option_button.add_item(version.version, id)
		
	version_option_button.selected = 0
	_on_version_selected(0)
	
	VersionTypeContainer.show()
	ButtonsContainer.show()
	Loading.hide()

func _on_version_selected(index: int) -> void:
	var version = actual_versions.get(index)
	var error = details_request.request(version.version_url)
	if error != OK:
			print('Something gone wrong')
	details_label.text = ''
	print(version.version)
	download_button.text = "Get Release %s" % [version.version]

func _on_net_selected(_index: int) -> void:
	_update_editor_specifications()

func _on_details_request_completed(_result, _response_code, _headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	actual_details = response
	
	_update_editor_specifications()
	
func _update_editor_specifications() -> void:
	var actual_version = actual_versions.get(version_option_button.selected)
	
	for version in actual_details:
		if version['filename'].match("BlaziumEditor_v%s_%s%s.%s.zip" % [actual_version.version,Settings.os_name,"" if net_include.selected != 1 else ".mono",Settings.os_arch]):
			actual_download = version
	
	if not actual_download:
		return
		
	var raw_timestamp : String = actual_download.get("timestamp", "")
	var raw_size : float = actual_download.get("size", 0.0)

	var build_size : String = format_size(raw_size)
	var build_timestamp : String = format_timestamp(raw_timestamp)

	details_label.text = "%s - %s" % [build_size, build_timestamp]

func _on_download_button_pressed() -> void:
	if not actual_download:
		return
	var actual_version = actual_versions.get(version_option_button.selected)
	var file_name : String = "engine/%s_%s%s.zip" % [actual_version.version,actual_version.deploy_type,"" if net_include.selected != 1 else "_mono"]
	DownloadManager.add_to_download(actual_download['download_url'],Settings.path.path_join(file_name))

func format_size(bytes: float) -> String:
	if bytes <= 0:
		return "0 B"
	
	var units = ["B", "KB", "MB", "GB", "TB"]
	var index = min(floor(log(bytes) / log(1024)), units.size() - 1)
	var value = bytes / pow(1024, index)
	
	return "%.1f %s" % [value, units[index]]


func format_timestamp(iso_string: String) -> String:
	if iso_string.is_empty():
		return "Nieznana data"
		
	var months = {
		1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
		7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
	}
	
	var datetime = Time.get_datetime_dict_from_datetime_string(iso_string, false)
	
	var month_name = months.get(datetime.month, "Unk")
	
	return "%s %d, %d" % [month_name, datetime.day, datetime.year]
