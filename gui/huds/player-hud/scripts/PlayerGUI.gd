class_name PlayerGUI
extends CanvasLayer
##########################  NODE REFERENCES ####################################
onready var world = get_tree().get_root().find_node("World", true, false)
onready var gui = $"."

onready var game_over_background = $GameOverBackground
onready var player_info_control = $PlayerInfoControl

onready var player_bar_control = $PlayerInfoControl/PlayerBarControl

onready var player_health_bar = $PlayerInfoControl/PlayerBarControl/PlayerHealthBar
onready var player_special_bar = $PlayerInfoControl/PlayerBarControl/PlayerSpecialBar
onready var player_elemental_bar = $PlayerInfoControl/PlayerBarControl/PlayerElementalBar
onready var player_icon = $PlayerInfoControl/PlayerBarControl/PlayerIcon

onready var coins_icon = $PlayerInfoControl/CoinsIcon
onready var coins_counter = $PlayerInfoControl/Coins
onready var score = $PlayerInfoControl/Score

onready var player_messages_control = $PlayerMessagesControl
onready var player_manna_message = $PlayerMessagesControl/PlayerMannaMessage
onready var player_elemental_message = $PlayerMessagesControl/PlayerElementalMessage

onready var sounds = $Sounds

onready var game_over_sound = $Sounds/GameOver

onready var animator = $Animator
onready var message_animator = $MessageAnimator

onready var pause_menu = $PauseMenu
onready var you_died_screen = $YouDiedScreen
###############################  CONSTANTS  ####################################

###############################  VARIABLES  ####################################
#var coins = 0
#onready var points
onready var player = get_tree().get_nodes_in_group("Player")[0] #This is a reference to the player and its camera

func _ready():
# warning-ignore:unused_variable
	pause_menu.visible = false
#	you_died_screen.visible = false
	player_manna_message.visible = false
	player_elemental_message.visible = false
	
	player_health_bar.max_value = player.max_health
	player_special_bar.max_value = player.max_special
	player_elemental_bar.max_value = player.max_elemental
	
	#We set the player icon depending on the selected character.
	if player.is_in_group("Fire"):
		player_icon.texture = load("res://characters/players/fire_man/assets/FiremanIconGUI.png")
	elif player.is_in_group("Spear"):
		player_icon.texture = load("res://characters/players/spear_woman/assets/SpearWomanIconGUI.png")
	elif player.is_in_group("Viking"):
		player_icon.texture = load("res://characters/players/viking/assets/VikingIconGUI.png")

func _process(_delta):
	coins_counter.text = str(GAME.coins)
	score.text = str(GAME.score)
	#This is similar to an instance of in Java
	if is_instance_valid(player):
		player_health_bar.value = player.health
		player_special_bar.value = player.special
		player_elemental_bar.value = player.elemental
#		$PlayerInfoControl/ScoreContainer/Coins.text = str("x") = str(GLOBAL.coins)
	manage_player_messages()

#func handle_picked_coins():
#	print("You just picked a coin!")
#	coins += 1
#	coins_counter.text = String(coins)

"""By using this function the GUI shows a message in order to make the player know that he doesn't have
# mana enough for casting more spells, that he can't ult if he doesn´t have elemental power enough and 
# that we can't transform if it stills in cooldown."""
func manage_player_messages():
	#When the player special value reaches 0
	if player.special <= 0 and !player_manna_message.visible and animator.is_playing():
		player_manna_message.visible = true
#		if player_message.visible:
		animator.play("show_manna_message")
	#The player tries to transform when elemental != elemental_max_value
	if player.elemental <= 0 and !player_elemental_message.visible:
		player_elemental_message.visible = true
#		if player_message.visible:
		animator.play("show_elemental_message")
		
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade-out":
			get_tree().paused = true
			game_over_sound.play()
			you_died_screen.visible = true
#			gui.get_parent().add_child(you_died_panel)
		"show_elemental_message":
			player_elemental_message.visible = false
		"show_manna_message":
			player_manna_message.visible = false

func _on_PlayerHealthBar_value_changed(value):
	if value <= 0:
		game_over_background.visible = true
		animator.play("fade-out")

# warning-ignore:unused_argument
func _on_PlayerSpecialBar_value_changed(value):
	#When the player special value reaches 0
	if player.special <= 0 and !player_manna_message.visible:
		player_manna_message.visible = true
#		if player_message.visible:
		animator.play("show_manna_message")

func _on_PlayerElementalBar_value_changed(value):
	if value <= 0 and !player_elemental_message.visible:
		player_elemental_message.visible = true
#		if player_message.visible:
		animator.play("show_elemental_message")
