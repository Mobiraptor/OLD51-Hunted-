extends Area2D

onready var texture_open = $Open
onready var texture_closed = $Closed
onready var vamp = get_node("../Vamp")
onready var hunter = get_node("../Hunter")
onready var timer = $Timer
onready var closed = 0
onready var pickable = 0
onready var stun_time = 3



func _on_Trap_body_entered(body):
	if body is Vamp and (closed == 0):
		texture_open.visible = 0
		texture_closed.visible = 1
		var stunned = body.stun(stun_time)
		if stunned == 1:
			timer.start(stun_time)
		else:
			 pickable = 1
		closed = 1
	elif body is Hunter and (closed==1) and (pickable==1):
		hunter.traps_count+=1
		hunter.max_traps_tip.set_text("Traps available "+String(hunter.traps_count))
		queue_free()

func _on_Timer_timeout():
	vamp.vamp_state_trapped = 0
	vamp.stun_msg.visible = 0
	pickable=1
