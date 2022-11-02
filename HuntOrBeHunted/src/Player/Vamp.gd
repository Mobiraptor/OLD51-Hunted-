extends KinematicBody2D

class_name Vamp

signal died

const SPEED := 450
const JUMP_STRENGTH := -300.0
const damage = 20
const dodge_cd_value = 5
const max_hunger = 140
onready var hunger = max_hunger
#onready var hunger = 10

var diedVar = false

var GRAVITY := 1000

var velocity = Vector2()

onready var vamp_state_trapped = 0
var rotated = false

var isNight = true
var isRope = false

#export var controls:Resource = null
var controls = preload("res://src/Player/player_1_controls.tres")

var player_substate = "idle"
var dodge_allowed_substates = ['idle','running']
var attack_allowed_substates = ['idle','running']
var stunned
var did_damage = 0

onready var player :=$"."
onready var animation := $AnimationPlayer
onready var sprite := $AnimatedSprite
onready var attack_time = $Attack/AttackTime
onready var attack_hitbox = $Attack
onready var stun_timer = $StunTimer
onready var dodge_cd_bar = $DodgeSkill/DodgeCDBar
onready var dodge_cd_timer = $DodgeSkill/DodgeCDTimer
onready var dodge_state_timer = $DodgeSkill/DodgeStateTimer
onready var hunger_bar = $HungerBar
onready var hunger_bar_label = $HungerBar/Label
onready var stun_msg = $StunMSG
#onready var hunter = get_node("../Hunter")
onready var tween = $Tween
onready var camera = $Camera

onready var ui = [hunger_bar,stun_msg,dodge_cd_bar]

func _ready():
	velocity.y = 0
	velocity.x = 0
	dodge_cd_bar.max_value = dodge_cd_value
	hunger_bar.max_value = hunger
	animation.play("Idle")
	if is_network_master():
		setup_camera()

func _physics_process(delta):
	if is_network_master():
		_handle_skills()
		if vamp_state_trapped == 0:
			_handle_movement(delta)


func _process(delta):
	if is_network_master(): 
		stun_msg.set_text("Stun "+ String(int(stun_timer.time_left)+1))
		dodge_cd_bar.value = dodge_cd_timer.time_left
	hunger_bar_label.set_text("Hunger " + String(int(hunger)))
	hunger_bar.value = hunger
	hunger_decay(delta)
	#networking
	if is_network_master():
		rpc_unreliable("update_player",self.position,self.rotated,self.animation.current_animation)

func hunger_decay(delta):
	if isNight:
		hunger-=delta
	else: 
		hunger-=delta * 2
	if hunger <= 0 :
		died()
	
func _handle_movement(delta):
	if player_substate == "running":
		player_substate = "idle"
		animation.play("Idle")
	velocity.x = 0
	var x_input := Input.get_action_strength(controls.move_right) - Input.get_action_strength(controls.move_left)
	var y_input 
	
	if isRope:
		velocity.y = 0
		y_input = Input.get_action_strength(controls.move_down) - Input.get_action_strength(controls.move_up)
		velocity.y += y_input*SPEED
	else:
		y_input = 0
		velocity.y += GRAVITY * delta
		
	if isNight:
		velocity.x += x_input * SPEED
	else:
		velocity.x += x_input * SPEED * 0.5
		if isRope:
			velocity.y*=0.5
	
	
	var vector_input := Vector2(x_input, y_input);
	
	if (vector_input.length() == 0):
		velocity = move_and_slide(velocity, Vector2(0,-1))
		return;	
	
	if player_substate=="idle" and y_input == 0: #in allowed_substates_run: #будет бежать, если не использует скилы кроме блока)
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


func _handle_skills():
	if Input.is_action_just_pressed(controls.attack) and (player_substate in attack_allowed_substates):
		rpc("vampire_attack")
	if Input.is_action_just_pressed(controls.skill) and (player_substate in dodge_allowed_substates) and dodge_cd_timer.time_left == 0:
		rpc("vampire_dodge")

func setup_camera():
	camera.custom_viewport = get_node("../..")
	camera.make_current()

#skills
remotesync func vampire_attack():
	attack_time.start(0.5)
	attack_hitbox.monitoring = 1
	player_substate = "attacking"
	animation.play("Attack")
		
remotesync func vampire_dodge():
		dodge_cd_timer.start(dodge_cd_value)
		animation.play("Dodge")
		player_substate = "dodge"
		dodge_state_timer.start(1)
		dodge_cd_bar.visible = 1

func text_direction(text_node_array):
	for i in text_node_array:
		i.rect_scale*=Vector2(-1,1)
	
	
func getIsRope():
	return isRope

func setIsRope(newIsRope):
	isRope = newIsRope
		
func stun(stun_time):
	if player_substate == 'dodge':
		stunned = 0
	else:
		stunned = 1
		vamp_state_trapped=1
		if is_network_master(): stun_msg.visible = 1
		stun_timer.start(stun_time)
	return stunned

func setIsNight(newIsNight):
	isNight = newIsNight

func died():
	emit_signal("died")
	diedVar = true
	queue_free()

#signals
func _on_Attack_body_entered(body):
	if body is Hunter and (did_damage == 0):
		body.damage(damage)
		did_damage = 1
		hunger+=20
		if hunger>max_hunger:
			hunger = max_hunger

func _on_AttackTime_timeout():
	attack_hitbox.monitoring = 0
	player_substate = "idle"
	did_damage = 0
	animation.play("Idle")

func _on_DodgeStateTimer_timeout():
	player_substate = "idle"
	animation.play("Idle")

func _on_DodgeCDTimer_timeout():
	dodge_cd_bar.visible = 0

#network
puppet func update_player(coordinates, turned, animation_name):
	self.position = coordinates
	if turned!=rotated:
		text_direction(ui)
		scale.x = -scale.x
	self.rotated = turned
	self.animation.play(animation_name)
