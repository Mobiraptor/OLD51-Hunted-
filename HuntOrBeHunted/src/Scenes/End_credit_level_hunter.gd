extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var hunter = get_node("Hunter")
onready var vamp = get_node("Vamp")

onready var controls_1 = preload("res://src/Player/player_1_controls.tres")
onready var controls_2 = preload("res://src/Player/player_2_controls.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	hunter.controls = controls_2
	vamp.controls = controls_1
	vamp.died()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	get_tree().change_scene("res://src/start_menu/StartMenu.tscn")
	pass # Replace with function body.
