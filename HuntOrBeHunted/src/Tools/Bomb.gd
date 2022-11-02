extends RigidBody2D

onready var explosion_timer = $ExplosionTimer
onready var bomb_sprite = $Bomb
onready var smoke_sprite = $Smoke
onready var smoke_time = $SmokeTime
onready var bomb = $"."



func _ready():
	explosion_timer.start(0.5)
	





func _on_ExplosionTimer_timeout():
	bomb.set_mode(1)
	bomb.set_collision_mask_bit(4,0)
	bomb_sprite.visible = 0
	smoke_sprite.visible = 1
	smoke_time.start(6)
	


func _on_SmokeTime_timeout():
	queue_free()
