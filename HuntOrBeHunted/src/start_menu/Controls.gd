extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var main_menu = get_node("../Menu")
onready var controls_button = get_node("../ControlsButton")








func _on_Button_button_down():
	self.hide()
	main_menu.visible = 1
	controls_button.visible = 1
