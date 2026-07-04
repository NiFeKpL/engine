extends HBoxContainer

#const POPUP_ENGINE = preload("uid://ph0n88acsoxm")

func _on_button_button_down() -> void:
	SignalBusGlobal.change_page_requested.emit(SiteContainer.VALID_PAGES.ENGINE_DOWNLOAD)
	#var scene = POPUP_ENGINE.instantiate()
	#add_child(scene)
