extends CanvasLayer

var rules = 1

onready var controls_button = $ControlsButton
onready var controls_descript = $Controls
onready var main_menu = $Menu
# Called when the node enters the scene tree for the first time.







func _on_start_button_pressed():
	#pass
	get_tree().change_scene("res://src/Scenes/Main.tscn")




func _on_Button_button_down():
	controls_button.hide()
	main_menu.hide()
	controls_descript.visible = 1
