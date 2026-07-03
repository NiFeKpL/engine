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

	for button in buttons:
		if button != clicked_button:
			# set_block_signals(true) prevents this change from triggering 
			# _on_button_toggled again for the other buttons.
			button.set_block_signals(true)
			button.button_pressed = false
			button.set_block_signals(false)
