extends Node2D

class_name DayNightRoom
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var isNight = false

onready var spriteDay = $SpriteDay
onready var spriteNight = $SpriteNight

export var textureDay:Texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setIsNight(newIsNight):
	isNight = newIsNight
	spriteDay.visible = !isNight
	spriteNight.visible = isNight
