class_name PopupEngineItem extends HBoxContainer

@export var version : String = ""
@export var is_nightly : bool = false

@onready var name_label: Label = %NameLabel
@onready var nightly_version: PanelContainer = %NightlyVersion

func _ready() -> void:
	name_label.text = version if version != "" else "error"
	if is_nightly:
		nightly_version.show()
