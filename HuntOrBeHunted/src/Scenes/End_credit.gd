extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
