extends KinematicBody2D

class_name Hunter

signal died


const SPEED := 300
const JUMP_STRENGTH := -300.0

var HP = 100
var GRAVITY := 1000

var velocity = Vector2()

var rotated = false
var diedVar = false

var player_substate = "idle" 
#var smoke_allowed_substates = ['idle','running']

var isRope = false
var climbing = false

#export var controls:Resource = null
var controls = preload("res://src/Player/player_2_controls.tres")

const max_traps = 3
onready var traps_count = max_traps
const max_bombs = 1
onready var bomb_count = max_bombs
onready var bomb_cd_time = 30


#onready var trap = 
onready var player :=$"."
onready var animation := $AnimationPlayer
onready var sprite := $AnimatedSprite
onready var hpbar = $HPBar
onready var max_traps_tip = $MaxTraps
onready var bomb_cd_label = $BombCD
onready var bomb_cd_timer = $BombCDTimer
onready var vamp = get_node("../Vamp")
onready var tween = $Tween
onready var camera = $Camera

onready var ui = [hpbar,max_traps_tip,bomb_cd_label]

func _ready():
	animation.play("Idle")
	max_traps_tip.set_text("Traps available "+String(traps_count))
	if is_network_master():
		setup_camera()
		for i in ui:
			if i == bomb_cd_label: return
			i.visible = 1


func _physics_process(delta): 
	if !diedVar and is_network_master():
		_handle_movement(delta)

func _process(delta):
	#_handle_skills()
	if is_network_master():
		rpc_unreliable("update_player",self.position,self.rotated,self.animation.current_animation)
		if bomb_count<max_bombs:
			bomb_cd_label.set_text("Bomb CD "+String(int(bomb_cd_timer.time_left)+1))
	hpbar.value = HP
	
func _handle_movement(delta):
	if player_substate == "running":
		player_substate = "idle"
		animation.play("Idle")
	velocity.x = 0
	var x_input := Input.get_action_strength(controls.move_right) - Input.get_action_strength(controls.move_left)
	var y_input
	velocity.x += x_input * SPEED
	
	if isRope:
		velocity.y = 0
		y_input = Input.get_action_strength(controls.move_down) - Input.get_action_strength(controls.move_up)
		velocity.y += y_input*SPEED
	else:
		y_input = 0
		velocity.y += GRAVITY * delta
	
	var vector_input := Vector2(x_input, y_input);
	
	if (vector_input.length() == 0) and (player_substate == "idle"):
		velocity = move_and_slide(velocity, Vector2(0,-1))
		return;	
	
	if player_substate=="idle": #переключатель анимации
		player_substate = "running"
		animation.play("Run")
		
	if (vector_input.x < 0 and !rotated):
		text_direction(ui)
		rotated = true
		scale.x = -scale.x
	if (vector_input.x > 0 and rotated):
		text_direction(ui)
		rotated = false
		scale.x = -scale.x
			
	velocity = move_and_slide(velocity, Vector2(0,-1))

func text_direction(text_node_array):
	for i in text_node_array:
		i.rect_scale*=Vector2(-1,1)
	
func getIsRope():
	return isRope

func setIsRope(newIsRope):
	isRope = newIsRope

#func _handle_skills():
	#if Input.is_action_just_pressed(controls.attack):
		#pass#deploy_smoke()
	#if Input.is_action_just_pressed(controls.skill):
		#deploy_trap()
		

#func deploy_smoke():
	#pass

#func deploy_trap():
	#traps_count-=1
	#var trap = trap_scene.instance()
	#trap.position = player.position
	#get_parent().add_child(trap)
	#max_traps_tip.set_text("Traps available "+String(traps_count))

func setup_camera():
	camera.custom_viewport = get_node("../..")
	camera.make_current()

func damage(dmg):
	HP-=dmg
	if HP<=0:
		died()
	
func died():
	emit_signal("died")
	diedVar = true
	queue_free()
	


func _on_BombCDTimer_timeout():
	bomb_count+=1
	if is_network_master():
		bomb_cd_label.visible = 0
	

#network
puppet func update_player(coordinates, turned, animation_name):
	self.position = coordinates
	if turned!=rotated:
		text_direction(ui)
		scale.x = -scale.x
	self.rotated = turned
	self.animation.play(animation_name)
	


