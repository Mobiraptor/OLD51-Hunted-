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
	if is_instance_valid(vamp):
		vamp.position = Vector2(-28,-70)
	if is_instance_valid(hunter):
		hunter.position = Vector2(-28,-70)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if is_instance_valid(vamp):
		vamp.queue_free()
	if is_instance_valid(hunter):
		hunter.queue_free()
	#var menu = load("res://src/Scenes/Start_scene.tscn").instance()
	#get_node("/root").add_child(menu)
	#Network.game_ended()
	get_tree().change_scene("res://src/start_menu/StartMenu.tscn")
	
	queue_free()

