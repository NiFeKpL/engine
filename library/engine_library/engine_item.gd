class_name EngineItem extends PanelContainer

@export var version_label : Label
@export var type_label : Label
@export var mono_label : Label
@export var button: Button
@export var option_button : OptionButton

var version : String
var type : String
var is_net : bool
var directory : String

var uninstall : Callable = func():
	pass

func _ready() -> void:
	version_label.text = version
	type_label.text = type
	mono_label.text = "GDScript" if not is_net else "C#"
	button.pressed.connect(_on_uninstall_button_clicked)
	option_button.item_selected.connect(_on_item_selected)

func _on_item_selected(_index: int) -> void:
	match _index:
		0:
			OS.shell_open(ProjectSettings.globalize_path(directory))
		_:
			pass
	option_button.selected = -1

func _on_uninstall_button_clicked() -> void:
	SignalBusGlobal.engine_uninstalled.emit(directory)
	uninstall.call(directory)
	queue_free()
