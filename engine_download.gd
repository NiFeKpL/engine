extends CenterContainer

#@export var list : VBoxContainer

var http_request : HTTPRequest
var actual_versions : Array
#@onready var check_button: Button = $PanelContainer/VBoxContainer/ColorRect/HBoxContainer/CheckButton
@export var type_button : Button
@export var version_option_button : OptionButton

@export var VersionTypeContainer : HBoxContainer
@export var ButtonsContainer : HBoxContainer

@export var Loading : Label

var is_nightly : bool = false

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_request_completed)
	type_button.toggled.connect(_on_button_toggled)
	
	type_button.button_pressed = true
	
	version_option_button.get_popup().max_size.y = 300
	#var error = http_request.request("https://blazium.app/api/download-options/editor")
	#if error != OK:
		#print('Something gone wrong')

func _process(_delta: float) -> void:
	if Loading.visible == true:
		@warning_ignore("integer_division")
		var count : int = (Time.get_ticks_msec() / 500) % 4
		Loading.text = "Ładowanie" + ".".repeat(count)

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
	
	VersionTypeContainer.show()
	ButtonsContainer.show()
	Loading.hide()
	#nightly_versions = response['versions']['nightly']
	#release_versions = response['versions']['release']
	#generate_versions()
	

#func generate_versions() -> void:
	#if not list:
		#return
	#
	#for version in nightly_versions:
		#var item = POPUP_ENGINE_ITEM.instantiate()
		#item.version = "v" + version
		#item.is_nightly = true
		#list.add_child(item)
		#item.name = version + 'nightly'
	#
	#for version in release_versions:
		#var item = POPUP_ENGINE_ITEM.instantiate()
		#item.version = "v" + version
		#item.is_nightly = false
		#list.add_child(item)
		#item.name = version + 'regular'

#func _on_close_requested() -> void:
	#if is_instance_valid(http_request):
		#http_request.queue_free()
	#queue_free()
