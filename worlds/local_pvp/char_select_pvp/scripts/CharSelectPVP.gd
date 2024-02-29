class_name PvPCharacterSelection
extends Control

onready var BtnLeft_1 = $CenterContainer/Panel/VBoxContainer2/HBoxContainer/ContainerPlayer1/HBoxContainer/ButtonLeft
onready var BtnLeft_2 = $CenterContainer/Panel/VBoxContainer2/HBoxContainer/ContainerPlayer2/HBoxContainer/ButtonLeft2
onready var BtnRight_1 = $CenterContainer/Panel/VBoxContainer2/HBoxContainer/ContainerPlayer1/HBoxContainer/ButtonRight
onready var BtnRight_2 = $CenterContainer/Panel/VBoxContainer2/HBoxContainer/ContainerPlayer2/HBoxContainer/ButtonRight2

onready var animationP1 = $AnimationPlayer1
onready var animationP2 = $AnimationPlayer2

onready var labWP1 = $WinsP1
onready var labWP2 = $WinsP2

onready var parallax_layer1 = $ParallaxBackground/Layer1
onready var parallax_layer3 = $ParallaxBackground/Layer3
onready var parallax_layer4 = $ParallaxBackground/Layer4

onready var start_button = $CenterContainer/Panel/VBoxContainer2/StartGame

var rng = RandomNumberGenerator.new()

onready var level_pvp1 = "res://worlds/local_pvp/scenes/level1PVP.tscn"
onready var level_pvp2 = "res://worlds/local_pvp/scenes/level2PVP.tscn"

var num_map



var player1: Dictionary = {
	0: "fireman",
	1: "viking",
	2: "spearwoman"
}

var player2: Dictionary = {
	0: "fireman",
	1: "viking",
	2: "spearwoman"
}
var map: Dictionary = {
	0: "res://worlds/local_pvp/scenes/level1PVP.tscn",
	1: "res://worlds/local_pvp/scenes/level2PVP.tscn",
	2: "res://worlds/local_pvp/scenes/level3PVP.tscn"
}
var char_index_p1: int = 0
var char_index_p2: int = 0

func _ready():
	
	get_tree().paused = false
	animationP1.play(player1[char_index_p1])
	animationP2.play(player2[char_index_p2])
#	animationP2.play(player2[char_index_p2 + 1])
	focus()
	rng.randomize()
	num_map = rng.randi_range(0,2)
	print(num_map)
	
	labWP1.text = str(PVP.wins_p1)
	labWP2.text = str(PVP.wins_p2)
	
func focus():
	BtnLeft_1.grab_focus()
	BtnLeft_2.grab_focus()
	BtnRight_1.grab_focus()
	BtnRight_2.grab_focus()
	
func _process(delta):
	move_parallax()
	block_same_selection()

func move_parallax():
	parallax_layer1.motion_offset.x += 0.1
	parallax_layer3.motion_offset.x += 0.2
	parallax_layer4.motion_offset.x += 0.3

func block_same_selection():
	if char_index_p1 == char_index_p2:
		start_button.disabled = true
	else:
		start_button.disabled = false
func _on_ButtonLeft_pressed():
	char_index_p1 -= 1
	if char_index_p1 < 0:
		char_index_p1 = 2
	animationP1.play(player1[char_index_p1])

func _on_ButtonRight_pressed():
	char_index_p1 += 1
	if char_index_p1 > 2:
		char_index_p1 = 0
	animationP1.play(player1[char_index_p1])


func _on_ButtonLeft2_pressed():
	char_index_p2 -= 1
	if char_index_p2 < 0:
		char_index_p2 = 2
	animationP2.play(player2[char_index_p2])


func _on_ButtonRight2_pressed():
	char_index_p2 += 1
	if char_index_p2 > 2:
		char_index_p2 = 0
	animationP2.play(player2[char_index_p2])


func _on_StartGame_pressed():
	# BORRAR ESTE COMENTARIO Player 1 -> necesito variable en el GLOBAL para player2 
	# PLAYER 1
	if char_index_p1 == 0:
		PVP.char_nump1 = char_index_p1
	elif char_index_p1 == 1:
		PVP.char_nump1 = char_index_p1
	elif char_index_p1 == 2:
		PVP.char_nump1 = char_index_p1
	
	# PLAYER 2
	if char_index_p2 == 0:
		PVP.char_nump2 = char_index_p2
	elif char_index_p2 == 1:
		PVP.char_nump2 = char_index_p2
	elif char_index_p2 == 2:
		PVP.char_nump2 = char_index_p2
		
	get_tree().change_scene(map[num_map])

func _on_BackBT_pressed():
	get_tree().change_scene("res://gui/screens/main_menu/scenes/MainMenu.tscn")
