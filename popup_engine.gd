extends Window

@export var list : VBoxContainer

var http_request : HTTPRequest
var nightly_versions : Array
var release_versions : Array

const POPUP_ENGINE_ITEM = preload("uid://c386swvkjywxf")

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request("https://blazium.app/api/download-options/editor")
	if error != OK:
		print('Something gone wrong')

func _on_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	nightly_versions = response['versions']['nightly']
	release_versions = response['versions']['release']
	generate_versions()
	

func generate_versions() -> void:
	if not list:
		return
	
	for version in nightly_versions:
		var item = POPUP_ENGINE_ITEM.instantiate()
		item.version = "v" + version
		item.is_nightly = true
		list.add_child(item)
		item.name = version + 'nightly'
	
	for version in release_versions:
		var item = POPUP_ENGINE_ITEM.instantiate()
		item.version = "v" + version
		item.is_nightly = false
		list.add_child(item)
		item.name = version + 'regular'

func _on_close_requested() -> void:
	if is_instance_valid(http_request):
		http_request.queue_free()
	queue_free()
