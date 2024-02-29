class_name Level
extends Node2D

onready var background = $Background
onready var coins = $Coins
onready var mobs = $Coins
onready var end = $EndArea
onready var player_spawn = $PlayerSpawn
onready var level_animator = $LevelAnimator

#################################  VARIABLES ###################################
var game_mode : String = "SinglePlayer"
############################### SCENE REFERENCES ###############################
var selected_player = load(GAME.selected_character)
const player_gui = preload("res://gui/huds/player-hud/scenes/PlayerGUI.tscn")
const player_camera = preload("res://characters/players/fire_man/cameras/PlayerCamera.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	GAME.game_mode = "Level"
	#We load the selected character back on the character selection

	var player = selected_player.instance()
	var gui = player_gui.instance()
	var camera = player_camera.instance()
	
	#We set the controlls for that player to the Single Player mode Controls
	InputController.set_singleplayer_controls(player)
	
	if GAME.checkpoint:
		player_spawn.global_position = GAME.current_pos
	else:
		GAME.current_pos = player_spawn.global_position
	get_tree().get_current_scene().add_child(player)
	player.global_position = GAME.current_pos
	#We add the camera that is meant to follow the character
	get_tree().get_current_scene().add_child(camera)
	camera.current = true
	#We also add the GUI that stores the variables and shows the collected coins and score
	get_tree().get_current_scene().add_child(gui)
	GAME.save_game()
	level_animator.play("level_in")
