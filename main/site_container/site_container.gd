class_name SiteContainer extends MarginContainer

var actual_page : Control = null

enum VALID_PAGES {
	LIBRARY,
	ENGINE_DOWNLOAD,
	SETTINGS
}

const PAGES : Dictionary = {
	VALID_PAGES.LIBRARY: preload("uid://d1i3y1335ejxn"),
	VALID_PAGES.ENGINE_DOWNLOAD: preload("uid://d3w5lncdcllqg"),
	VALID_PAGES.SETTINGS: preload("uid://i5q30yldach7")
}

func open_page(page: VALID_PAGES) -> void:
	var get_page = PAGES.get(page)
	if get_page:
		if actual_page != null:
			actual_page.queue_free()
		actual_page = get_page.instantiate()
		add_child(actual_page)
