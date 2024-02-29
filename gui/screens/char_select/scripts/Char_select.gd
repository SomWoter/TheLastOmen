class_name CharacterSelection
extends Control

onready var animation = $AnimationPlayer

onready var btLeft= $CenterContainer/Panel/VBoxContainer/HBoxContainer/ButtonLeft
onready var btRight=$CenterContainer/Panel/VBoxContainer/HBoxContainer/ButtonRight
onready var btStart=$CenterContainer/Panel/VBoxContainer/StartGame

onready var parallax_layer1 = $ParallaxBackground/Layer1
onready var parallax_layer3 = $ParallaxBackground/Layer3
onready var parallax_layer4 = $ParallaxBackground/Layer4

###############################  SCENE REFERENCE ###############################
var singleplayer_introduction = "res://gui/screens/single_player_intro/scenes/SinglePlayerIntroduction.tscn"
var characters: Dictionary = {
	0: "fire_walk",
	1: "ice_walk",
	2: "light_walk"
}

var char_int : int = 1

func _ready():
	animation.play(characters[char_int])
	focus()

func focus():
	btLeft.grab_focus()
	btRight.grab_focus()
	btStart.grab_focus()

func _process(delta):
	move_parallax()

func move_parallax():
	parallax_layer1.motion_offset.x += 0.1
	parallax_layer3.motion_offset.x += 0.2
	parallax_layer4.motion_offset.x += 0.3
func _on_ButtonLeft_pressed():
		char_int -= 1
		if char_int < 0:
			char_int = 2
		animation.play(characters[char_int])


func _on_ButtonRight_pressed():
	char_int += 1
	if char_int > 2:
		char_int = 0
	animation.play(characters[char_int])


func _on_StartGame_pressed():
	if char_int == 0:
		GAME.selected_character = "res://characters/players/fire_man/scenes/FireMan.tscn"
	elif char_int == 2:
		GAME.selected_character = "res://characters/players/spear_woman/scenes/SpearWoman.tscn"
	elif char_int == 1:
		GAME.selected_character = "res://characters/players/viking/scenes/Viking.tscn"
#	GAME.create_game()
	get_tree().change_scene(singleplayer_introduction)


func _on_BackBT_pressed():
	get_tree().change_scene("res://gui/screens/load_new_game/scene/LoadNewGame.tscn")
