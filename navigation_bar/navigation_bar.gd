extends HBoxContainer

var buttons : Array[Button]

func _ready() -> void:
	for child in get_children():
		if child is Button:
			buttons.append(child)
			child.toggled.connect(_on_button_toggled.bind(child))

func _on_button_toggled(toggled_on: bool, clicked_button : Button) -> void:
	if not toggled_on:
		return
	if SiteContainer.VALID_PAGES.has(clicked_button.name.to_upper()):
		SignalBusGlobal.change_page_requested.emit(SiteContainer.VALID_PAGES.get(clicked_button.name.to_upper()))
	#print(clicked_button.name)
	#for button in buttons:
		#if button != clicked_button:
			#button.set_block_signals(true)
			#button.button_pressed = false
			#button.set_block_signals(false)
