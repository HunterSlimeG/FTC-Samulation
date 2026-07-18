extends Control

const defaultOnline = {
	"user":"",
	"lobby":"",
	"address":"127.0.0.1",
	"maxPlayers":2,
}
var onlineData = {
	"user":"",
	"lobby":"",
	"address":"127.0.0.1",
	"maxPlayers":2,
}
var onlinePath = "user://online.json"

var address = ""

var host = {}
var players = {}
var player = {"name":"user"}

func saveOnline(data: Dictionary):
	var file = FileAccess.open(onlinePath, FileAccess.WRITE)
	
	var json_string = JSON.stringify(onlineData)
	
	file.store_line(json_string)
	file.close()
func loadOnline():
	if not FileAccess.file_exists(onlinePath):
		saveOnline(defaultOnline)
	else:
		var file = FileAccess.open(onlinePath, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		onlineData = JSON.parse_string(json_string)
		for k in defaultOnline.keys():
			if not onlineData.has(k):
				onlineData[k] = defaultOnline[k]
	
	player.name = onlineData.user
	$LineEdit.text = onlineData.user
	$IP/IP.text = onlineData.address
	$Lobby/Lobby.text = onlineData.lobby
	$Lobby/Max2.value = onlineData.maxPlayers

func _ready() -> void:
	multiplayer.peer_connected.connect(connected)
	multiplayer.peer_disconnected.connect(disconnected)
	multiplayer.connected_to_server.connect(connected_client)
	multiplayer.connection_failed.connect(connected_fail)
	multiplayer.server_disconnected.connect(disconnected_client)
	
	loadOnline()
func _process(delta: float) -> void:
	$Players/ItemList.clear()
	var ids = players.keys()
	ids.sort()
	for id in ids:
		$Players/ItemList.add_item(str(players[id].name))
	if players.has(1):
		$Players/Host/Host.text = players[1].name

func _on_line_edit_text_submitted(new_text: String) -> void:
	onlineData.user = new_text
	player.name = onlineData.user
	saveOnline(onlineData)
func _on_max_2_value_changed(value: float) -> void:
	onlineData.maxPlayers = value
	saveOnline(onlineData)
func _on_lobby_text_submitted(new_text: String) -> void:
	onlineData.lobby = new_text
	saveOnline(onlineData)
func _on_ip_text_submitted(new_text: String) -> void:
	onlineData.address = new_text
	address = new_text
	saveOnline(onlineData)

func _on_create_pressed() -> void:
	$Create.disabled = true
	$Join.disabled = true
	$IP.visible = false
	$Lobby.visible = false
	$Players.visible = true
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(7000, onlineData.maxPlayers)
	multiplayer.multiplayer_peer = peer
	players[1] = player
func _on_join_pressed() -> void:
	$Create.disabled = true
	$Join.disabled = true
	$IP.visible = false
	$Lobby.visible = false
	$Players.visible = true
	if address.is_empty():
		address = defaultOnline.address
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, 7000)
	multiplayer.multiplayer_peer = peer
@rpc("any_peer", "reliable")
func register(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
func connected(id):
	register.rpc_id(id, player)
func disconnected(id):
	players.erase(id)
func connected_client():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player
func connected_fail():
	remove_multiplayer_peer()
func disconnected_client():
	remove_multiplayer_peer()
	players.clear()
