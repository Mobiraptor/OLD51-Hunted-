extends Node2D

onready var players:= {
	"1":  {
		viewport = $HBoxContainer/ViewportContainer/Viewport,
		camera = $HBoxContainer/ViewportContainer/Viewport/Camera2D,
		player = $HBoxContainer/ViewportContainer/Viewport/Level/Vamp
	},
	"2":  {
		viewport = $HBoxContainer/ViewportContainer2/Viewport,
		camera = $HBoxContainer/ViewportContainer2/Viewport/Camera2D,
		player = $HBoxContainer/ViewportContainer/Viewport/Level/Hunter
	}
}

func _ready():
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)

#func _physics_process(_delta):
	#if Input.is_action_just_pressed("clone"):
	#	_clone()
	#check_broken_list()
#	update_camera1(player1.position)

#func check_broken_list():
#	for child in brokenList.get_children():
#		if child is BrokenObject and child.has_method("GetStatus"):
#			if child.GetStatus() == true:
#				game_over()
			
func game_over() -> void:
	# need to check score - and if it high enough, call scene to enter name?
	get_tree().change_scene("res://src/Scenes/End_credit.tscn")
	
#func update_camera1(position):
#	camera.position = Vector2(position.x, position.y)
