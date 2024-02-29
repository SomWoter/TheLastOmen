extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip ="23.88.112.254"
#var ip = "127.0.0.1"
var port = 1910
var cert = load("res://info/X509_Certificate.crt")

var username
var password
var new_account = false

var is_login = false

#
## warning-ignore:unused_argument
#func _process(delta):
#	# Checks constantly the connection between the getway and game server
#	if get_custom_multiplayer() == null:
#		return
#	if not custom_multiplayer.has_network_peer():
#		return;
#	custom_multiplayer.poll();

# Method that creates the client to can start the connection with other servers
func ConnectToServer(_username, _password, _new_account):
	new_account = _new_account
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) # Set to true when using signed certificate
	network.set_dtls_certificate(cert)
	# Saves the username and password to be used in another method
	username = _username
	password = _password
	# Creates the client
	network.create_client(ip, port)
	#Creates the multiplayer interface
	set_custom_multiplayer(gateway_api)
	
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	# Calls _OnConnectionFailed method when the connection fails
	network.connect("connection_failed", self, "_OnConnectionFailed")
	# Calls _OnConnectionSucceeded method when the connection succeeds
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

# Method called when the connection fails
func _OnConnectionFailed():
	#TODO
	print("Failed to connet to login server")
	print("Pop-up server offline or something")
	# IF connection fails, then turn on the button again to try a new request
	print(is_login)
	
	if is_login:
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").return_button.disabled = false
	else:
		get_node("../RegisterScreen").confirm_button.disabled = false
		get_node("../RegisterScreen").return_button.disabled = false
		pass

# Method called when the connection succeeds
func _OnConnectionSucceeded():
	print("Succesfully connected to gatewayr")
	if new_account == true:
		RequestCreateAccount()
	else:	
		# Send the new Request
		RequestLogin()

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1,"CreateAccountRequest", username, password)
	username = ""
	password = ""

remote func ReturnCreateAccountRequest(results, message):
	print("Results received from createAccount: ")
	print("Message: ", message)
	if results == true:
		get_node("../RegisterScreen").notification.modulate = Color(0, 0.8, 0, 1)
		get_node("../RegisterScreen").notification.text = "Account created successfully!"
		yield(get_tree().create_timer(1), "timeout")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://gui/screens/login/scenes/LoginScreen.tscn")
	else:
		if message == 1:
			get_node("../RegisterScreen").notification.modulate = Color(1, 0, 0, 1)
			get_node("../RegisterScreen").notification.text = "Error ocurred, try again later!"
			
		elif message == 2:
			get_node("../RegisterScreen").notification.modulate = Color(1, 0, 0, 1)
			get_node("../RegisterScreen").notification.text = "Username already exists!"
		
		get_node("../RegisterScreen").confirm_button.disabled = false
		get_node("../RegisterScreen").back_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
		
# Send username and password to the gateway as a login request
func RequestLogin():
	get_node("../LoginScreen").notification.text = "Verifying..."
	print("Connecting to gateway to request login")
	# Executes the LoginRequest method from the GateWay server giving username and passowrd
	rpc_id(1, "LoginRequest", username, password)
	# Empties the local vars
	username = ""
	password = ""

# MEthod callable from the Gateway to receive the result and token created in the Authenticate Server
remote func ReturnLoginRequest(results, token):
	print("Results received:")
	print("Results: " , results)
	print("Token:  ", token)
	# If result is true, 
	if results == true:
	# Saves the token into GameServer script
		GameServer.token = token
	# calls the method to Connect to the GameServer
		#GameServer.ConnectToServer()
	# And opens the main menu
	
		
		get_node("../LoginScreen").notification.modulate = Color(0, 1, 0, 1)
		get_node("../LoginScreen").notification.text = "Connecting..."
		get_tree().change_scene("res://gui/screens/main_menu/scenes/MainMenu.tscn")
	# Else
	else:
		
		get_node("../LoginScreen").notification.modulate = Color(1, 0, 0, 1)
		get_node("../LoginScreen").notification.text = "Incorrect username or password!"
		# Turns on the button of LOGIN to be able to send new request
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").return_button.disabled = false
	# Checks the connection calling the correspondent method
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
