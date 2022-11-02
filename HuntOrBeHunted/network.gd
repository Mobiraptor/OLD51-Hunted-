extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2

var server = null
var client = null

var ip_adress = ""

func _ready():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			ip_adress = ip
	
	get_tree().connect("connected_to_server",self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

func _connected_to_server():
	print("succs ass fully connected")
	
func _server_disconnected():
	print ("bitch disconnected") 

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	get_tree().set_network_peer(server)
	
func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_adress, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func game_ended():
	server.set_refuse_new_network_connections(false)
	get_tree().network_peer = null
