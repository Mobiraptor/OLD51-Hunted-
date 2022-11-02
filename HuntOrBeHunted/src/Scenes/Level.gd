extends Node

class_name Level





onready var trap_scene = preload("res://src/Tools/Trap.tscn")
onready var bomb_scene = preload("res://src/Tools/Bomb.tscn")

onready var hunter = get_node("Hunter")
onready var vamp = get_node("Vamp")


onready var roomList = $RoomList
onready var timer = $Timer
onready var startCounter = $TimeToLoad/TimeToLoadCounter
onready var startTimer = $TimeToLoad

onready var controls_1 = preload("res://src/Player/player_1_controls.tres")
onready var controls_2 = preload("res://src/Player/player_2_controls.tres")

var isNight = true

		
func _ready():
	get_tree().set_pause(true)
	#hunter.controls = controls_2
	#vamp.controls = controls_1
	#pass

func _process(delta):
	if is_instance_valid(hunter) and hunter.is_network_master():
		if Input.is_action_just_pressed(hunter.controls.skill) and (hunter.traps_count>0):
			print(is_network_master())
			rpc("_setup_trap")
		if Input.is_action_just_pressed(hunter.controls.attack) and (hunter.bomb_count>0):
			rpc("_setup_bomb")
	if not is_instance_valid(hunter):
		hunter = get_node("Hunter")
		hunter.connect("died", self, "_on_Hunter_died")
	if not is_instance_valid(vamp):
		vamp = get_node("Vamp")
		vamp.connect("died", self, "_on_Vamp_died")
	if startTimer.time_left>0:
		print(String(int(startTimer.time_left + 1)))
		startCounter.text = int(startTimer.time_left + 1)

#func connect_player_nodes(node,node_name):
	#if not is_instance_valid(node):
		#node = get_node(node_name)
		#get_tree().connect("died", self, "_on_" + node_name + "_died")
		
remotesync func _setup_trap():
	hunter.traps_count-=1
	var trap = trap_scene.instance()
	trap.position = hunter.position
	add_child(trap)
	hunter.max_traps_tip.set_text("Traps available "+String(hunter.traps_count))
	
remotesync func _setup_bomb():
	hunter.bomb_count-=1
	var bomb = bomb_scene.instance()
	bomb.position = hunter.position
	add_child(bomb)
	hunter.bomb_cd_timer.start(hunter.bomb_cd_time)
	hunter.bomb_cd_label.visible = 1
	
func _on_Hunter_died():
	rpc("end_screen")
	#get_tree().change_scene("res://src/Scenes/End_credit_level.tscn")
	

func _on_Timer_timeout():
	isNight = !isNight
	for room in roomList.get_children():
		if room is DayNightRoom and room.has_method("setIsNight"):
			room.setIsNight(isNight)
	vamp.setIsNight(isNight)


func _on_Vamp_died():
	rpc("end_screen")
	#get_tree().change_scene("res://src/Scenes/End_credit_level.tscn")

remotesync func unpause():
	get_tree().set_pause(false)

remotesync func end_screen():
	#var end_level = load('res://src/Scenes/End_credit_level.tscn').instance()
	#get_node("/root").add_child(end_level)
	get_tree().change_scene("res://src/Scenes/End_credit_level.tscn")
	queue_free()


func _on_TimeToLoad_timeout():
	rpc("unpause")
	startCounter.visible = 0
