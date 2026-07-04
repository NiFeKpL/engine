extends Control

@export var site_container : SiteContainer

func _ready() -> void:
	site_container.open_page(SiteContainer.VALID_PAGES.LIBRARY)
	SignalBusGlobal.change_page_requested.connect(site_container.open_page)
	pass
