class_name PvPGUI
extends CanvasLayer
#############################  NODE REFERENCES #################################
onready var p2_bar_control =  $PInfoControl/P2BarControl
onready var p2_health_bar = $PInfoControl/P2BarControl/P2HealthBar
onready var p2_special_bar = $PInfoControl/P2BarControl/P2SpecialBar
onready var p2_elemental_bar =$PInfoControl/P2BarControl/P2ElementalBar
onready var p2_player_icon = $PInfoControl/P2BarControl/P2PlayerIcon

onready var p1_bar_control =  $PInfoControl/PBarControl
onready var p1_health_bar = $PInfoControl/P1BarControl/P1HealthBar
onready var p1_special_bar = $PInfoControl/P1BarControl/P1SpecialBar
onready var p1_elemental_bar =$PInfoControl/P1BarControl/P1ElementalBar
onready var p1_player_icon = $PInfoControl/P1BarControl/P1PlayerIcon

onready var pause_menu = $PauseMenuPvP
onready var you_died_screen = $YouDiedScreen

onready var player_messages_control = $PlayerMessagesControl
onready var player_manna_message = $PlayerMessagesControl/PlayerMannaMessage
onready var player_elemental_message = $PlayerMessagesControl/PlayerElementalMessage

onready var animator = $Animator

onready var game_over_sound = $Sounds/GameOver

onready var game_over_background = $GameOverBackground
onready var game_finish = $FinishPanel
onready var finish_label = $FinishPanel/YouDiedPanel/Winner

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var player2 = get_tree().get_nodes_in_group("Player")[1]

func _ready():
	pause_menu.visible = false
	player_manna_message.visible = false
	player_elemental_message.visible = false
	
	p2_health_bar.max_value = player2.max_health
	p2_special_bar.max_value = player2.max_special
	p2_elemental_bar.max_value = player2.max_elemental
	
	p1_health_bar.max_value = player.max_health
	p1_special_bar.max_value = player.max_special
	p1_elemental_bar.max_value = player.max_elemental
	

	if player2.is_in_group("Fire"):
		p2_player_icon.texture = load("res://characters/players/fire_man/assets/FiremanIconGUI.png")
	elif player2.is_in_group("Spear"):
		p2_player_icon.texture = load("res://characters/players/spear_woman/assets/SpearWomanIconGUI.png")
	elif player2.is_in_group("Viking"):
		p2_player_icon.texture = load("res://characters/players/viking/assets/VikingIconGUI.png")
	
	if player.is_in_group("Fire"):
		p1_player_icon.texture = load("res://characters/players/fire_man/assets/FiremanIconGUI.png")
	elif player.is_in_group("Spear"):
		p1_player_icon.texture = load("res://characters/players/spear_woman/assets/SpearWomanIconGUI.png")
	elif player.is_in_group("Viking"):
		p1_player_icon.texture = load("res://characters/players/viking/assets/VikingIconGUI.png")
		
func _process(delta):
	if is_instance_valid(player2):
		p2_health_bar.value = player2.health
		p2_special_bar.value = player2.special
		p2_elemental_bar.value = player2.elemental


	if is_instance_valid(player):
		p1_health_bar.value = player.health
		p1_special_bar.value = player.special
		p1_elemental_bar.value = player.elemental

	manage_player_messages()
	
func manage_player_messages():
	#When the player special value reaches 0
	if player2.special <= 0 and !player_manna_message.visible and animator.is_playing():
		player_manna_message.visible = true
#		if player_message.visible:
		animator.play("show_manna_message")
	#The player tries to transform when elemental != elemental_max_value
	if player2.elemental <= 0 and !player_elemental_message.visible:
		player_elemental_message.visible = true
#		if player_message.visible:
		animator.play("show_elemental_message")
		
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

func _on_P2HealthBar_value_changed(value):
	if value <= 0:
		game_over_background.visible = true
		PVP.wins_p1 +=1
		animator.play("fade-out")


func _on_P2SpecialBar_value_changed(value):
	if player2.special <= 0 and !player_manna_message.visible:
		player_manna_message.visible = true
#		if player_message.visible:
		animator.play("show_manna_message")


func _on_P2ElementalBar_value_changed(value):
	if value <= 0 and !player_elemental_message.visible:
		player_elemental_message.visible = true
#		if player_message.visible:
		animator.play("show_elemental_message")


func _on_Animator_animation_finished(anim_name):
	match anim_name:
		"fade-out":
			get_tree().paused = true
			game_over_sound.play()
			game_finish.visible = true
			if player.health <=0:
				finish_label.text = "PLAYER 2 WINS"
			elif player2.health<=0:
				finish_label.text = "PLAYER 1 WINS"
			
#			gui.get_parent().add_child(you_died_panel)
		"show_elemental_message":
			player_elemental_message.visible = false
		"show_manna_message":
			player_manna_message.visible = false







func _on_P1HealthBar_value_changed(value):
	if value <= 0:
		game_over_background.visible = true
		PVP.wins_p2 +=1
		animator.play("fade-out")


func _on_P1SpecialBar_value_changed(value):
	if player.special <= 0 and !player_manna_message.visible:
		player_manna_message.visible = true
#		if player_message.visible:
		animator.play("show_manna_message")


func _on_P1ElementalBar_value_changed(value):
	if value <= 0 and !player_elemental_message.visible:
		player_elemental_message.visible = true
#		if player_message.visible:
		animator.play("show_elemental_message")
