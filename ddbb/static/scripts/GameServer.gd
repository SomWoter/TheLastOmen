extends Node

var network
var ip = "23.88.112.254"
#var ip ="127.0.0.1"
var port = 1909
var cert = load("res://info/X509_Certificate.crt")

var connected
var key = "the last omen xx"

func _ready():
	pass

func ConnectToServer():
	if GAME.username != "guest":
		network = NetworkedMultiplayerENet.new()
		print("CONNECT TO GAMESERVER")
		network.set_dtls_enabled(true)
		network.set_dtls_verify_enabled(false) # Set to true when using signed certificate
		network.set_dtls_certificate(cert)
		network.create_client(ip, port)
		get_tree().set_network_peer(network)
		network.connect("connection_failed", self, "_OnConnectionFailed")
		network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect to GameServer")
	network = null
	connected = false

func _OnConnectionSucceeded():
	print("Succesfully connected to GameServer")
	connected = true
	
func registerRequest(username, password):
	if connected == true:
		yield(get_tree().create_timer(0.2), "timeout")
		print("\nSending register request--")
		var player_id = get_tree().get_network_unique_id()
#		var encrypted_username = encrypt(username)
#		var encrypted_password = encrypt(password)
		var encrypted_password = password.md5_text()
		rpc_id(1, "registerRequest", player_id, username, encrypted_password)
	elif !connected:
		
		get_node("../RegisterScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../RegisterScreen").notification.text = "Connection failed. Restart and try again!"
		# Turns on the button of LOGIN to be able to send new request
		get_node("../RegisterScreen").confirm_button.disabled = false
		get_node("../RegisterScreen").back_button.disabled = false
		
func loginRequest(username, password):
	if connected == true:
		var player_id = get_tree().get_network_unique_id()
		var encrypted_password = password.md5_text()
		rpc_id(1, "loginRequest", player_id, username, encrypted_password)
		
	elif !connected:
		
		get_node("../LoginScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../LoginScreen").notification.text = "Connection failed. Restart and try again!"
		# Turns on the button of LOGIN to be able to send new request
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").back_button.disabled = false
	
remote func resultRegisterRequest(result):
	print("Result from register: ", result)
	if result:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://gui/screens/login/scenes/LoginScreen.tscn")
	elif !result:
		get_node("../RegisterScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../RegisterScreen").notification.text = "Username already exists!"	
		yield(get_tree().create_timer(0.2), "timeout")
		get_node("../RegisterScreen").confirm_button.disabled = false
		get_node("../RegisterScreen").back_button.disabled = false
	else:
		get_node("../RegisterScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../RegisterScreen").notification.text = "Something went wrong..."
	# Turns on the button of LOGIN to be able to send new request
		yield(get_tree().create_timer(0.2), "timeout")
		get_node("../RegisterScreen").confirm_button.disabled = false
		get_node("../RegisterScreen").back_button.disabled = false
		
remote func resultLoginRequest(id_user, result):
	print("Login result from server: " , result)
	if result:
		print("Login result id_user: ", id_user)
		GAME.id_user = id_user
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://gui/screens/main_menu/scenes/MainMenu.tscn")
	else:
		get_node("../LoginScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../LoginScreen").notification.text = "Incorrect username or password!"
		# Turns on the button of LOGIN to be able to send new request
		yield(get_tree().create_timer(0.2), "timeout")
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").back_button.disabled = false
		
func SavePlayerData(data):
	rpc_id(1, "SavePlayerData", data)

func LoadPlayerData():
	var player_id = get_tree().get_network_unique_id()
	print("---------------------------> LoadPlayer", GAME.id_user)
	rpc_id(1 , "LoadPlayerData", player_id, GAME.id_user)
	
remote func getLoadPlayerData(received_data):
	print("getLoadPlayerData " , received_data )
	if received_data != null:
		if received_data.size() > 0:
				GAME.data = received_data
				print("\n GAME DATA NOW IS: \n", GAME.data )
	else:
		printerr("getLoadPlayerData received_data is null: ", received_data)

func DeleteRequest(id_user):
	rpc_id(1, "DeleteRequest", id_user)

func GetScores():
	print("ASKING FOR SCORES")
	var player_id = get_tree().get_network_unique_id()
	rpc_id(1, "GetScores", player_id)
	

remote func resultGetScores(received_data):
	print("\nRECEIVED RESULT SCORES: " , received_data)
	GAME.data = received_data

# 
func saveScore(id_user):
	print("SAVING SCORE")
	print("DATA IN THIS MOMENT IS: " , GAME.data)
	
	rpc_id(1, "Check_HighScore_Player", id_user)

func get_Check_HighScore_Player():
	print("\n get_Check_HighScore_Player \n")
	var player_id = get_tree().get_network_unique_id()
	print("\nID:USER SENT: ", GAME.id_user, "\n")
	rpc_id(1, "get_Check_HighScore_Player", player_id, GAME.id_user)
	
remote func Check_HighScore_Player(highscore_score):
	print("Check_HighScore_Player score is -> ", highscore_score)
	if highscore_score!= null:
		print("\n=== DATA ===\n ", GAME.data)
		print("\n === DATA \n" , highscore_score)
		print("\n ==== DATA CON SCORE ####: " , GAME.data)
		print("Highscore.score: " , highscore_score , " GAME.data.score: " , str(GAME.data.score))
		if highscore_score < GAME.data.score:
			# GUARDAR
			print("\nGUARDAR NUEVO SCORE\n")
			var path = GAME.data.selected_character
			var char_name = path.get_file().get_basename().to_lower()
			print(char_name)  # Out
			print("GAME : " , GAME.username)
			var new_highscore = {
				"id_highscore" : GAME.id_user,
				"id_game" : GAME.id_user,
				"username" : GAME.username,
				"selected_character" : char_name,
				"mobs_killed" : GAME.data.mobs_killed,
				"coins" : GAME.data.coins,
				"score" : GAME.data.score
			}
			rpc_id(1, "SaveScore", new_highscore)
			pass
		else:
			# NO GUARDAR
			print("\nNO GUARDAR NUEVO SCORE\n")
			pass
	else:
				# GUARDAR
		print("\nGUARDAR NUEVO SCORE\n")
		var path = GAME.data.selected_character
		var char_name = path.get_file().get_basename().to_lower()
		print(char_name)  # Out
		print("GAME : " , GAME.username)
		var new_highscore = {
			"id_highscore" : GAME.id_user,
			"id_game" : GAME.id_user,
			"username" : GAME.username,
			"selected_character" : char_name,
			"mobs_killed" : GAME.data.mobs_killed,
			"coins" : GAME.data.coins,
			"score" : GAME.data.score
		}
		rpc_id(1, "SaveScore", new_highscore)
