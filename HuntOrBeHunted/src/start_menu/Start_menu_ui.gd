extends Control


onready var multiplayer_menu_layer = $Multiplayer_configure
onready var lobby_menu = $Lobby
onready var lobby_list = $Lobby/LobbyList
onready var server_ip = $ServerIp
onready var client_ip = $Multiplayer_configure/LineEdit
onready var start_button = $Lobby/StartButton
onready var menu = get_node("../TextureRect2")
onready var menu_node = get_parent()


var player_info = {}
# Info we send to other players
var my_info = { text = "Awaiting server"}

var second_player_id
var self_id
onready var i = 12

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	
	
	server_ip.text = Network.ip_adress
	client_ip.text = Network.ip_adress

func _player_connected(id):
	print ("Player "+str(id)+ " has connected")
	rpc_id(id, "register_player", my_info)
	if self_id == 1:
		start_button.visible = 1
	#second_player_id = get_tree().get_rpc_sender_id()
	
	#menu.visible = 0

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	second_player_id = id
	print(second_player_id)
	# Store the info
	player_info[id] = info
	for i in info:
		lobby_list.add_item(String(info[i]))
	Network.server.set_refuse_new_network_connections(true)

func _player_disconnected(id):
	lobby_list.clear()
	print ("Player "+str(id)+ " has disconnected")


func _on_Create_server_pressed():
	multiplayer_menu_layer.hide()
	lobby_menu.visible = 1
	Network.create_server()
	self_id = get_tree().get_network_unique_id()


func _on_Connect_pressed():
	if server_ip.text != "":
		my_info = { text = "Player 2 connected. Waiting for start"}
		multiplayer_menu_layer.hide()
		lobby_menu.visible = 1
		Network.ip_adress = client_ip.text
		Network.join_server()
		

remote func hide_menu():
	start_button.visible = 0
	lobby_menu.hide()

remotesync func load_game(selfPeerID,p):
	
	#get_tree().change_scene("res://src/Scenes/Main.tscn")
	menu.visible = 0
	#var selfPeerID = get_tree().get_network_unique_id()
	print(selfPeerID,"   ",p)
	# Load world
	var camera = load("res://src/Player/View.tscn").instance()
	get_node("/root").add_child(camera)
	
	var world = load('res://src/Scenes/Level.tscn').instance()
	get_node("/root/View").add_child(world)
	#var viewport = load("res://src/player/PlayerWiewport.tscn").instance()
	#get_node("/root/Room").add_child(viewport)

	# Load my player
	var my_player = preload("res://src/Player/Vamp.tscn").instance()
	my_player.set_name("Vamp")
	my_player.set_network_master(selfPeerID) # Will be explained later
	#print(my_player,is_network_master())
	get_node("/root/View/Room").add_child(my_player)

	# Load other players
	#for p in player_info:
	var player = preload("res://src/Player/Hunter.tscn").instance()
	player.set_name("Hunter")
	player.set_network_master(p) # Will be explained later
	#print(p,is_network_master())
	get_node("/root/View/Room").add_child(player)
	
	#if selfPeerID == self_id:
		#get_tree().set_pause(true)
	#else:
		#rpc("unpause_server")
	menu_node.queue_free()
	
		
remote func unpause_server():
	get_tree().set_pause(false)
	menu_node.queue_free()
	
func _on_StartButton_pressed():
	
	hide_menu()
	rpc("hide_menu")
	print(self_id,"   ",second_player_id)
	#load_game(self_id,second_player_id)
	rpc("load_game",self_id,second_player_id)
	
	



