extends HBoxContainer

const POPUP_ENGINE = preload("uid://ph0n88acsoxm")

func _on_button_button_down() -> void:
	var scene = POPUP_ENGINE.instantiate()
	add_child(scene)
