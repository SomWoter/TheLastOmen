class_name PvPLevel
extends Node2D

var game_mode : String = "PvP"
var player1 : Player
var player2 : Player

onready var spawnp1 = $SpawnP1
onready var spawnp2 = $SpawnP2

var p1
var p2

const player_gui = preload("res://gui/huds/pvp-hud/scenes/PvPGUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	unlock_player_abilities()
	get_tree().paused = false
	GAME.game_mode = "PvPLevel"
	p1 = PVP.load_num()
	p2 = PVP.load_num2()
	
	if p1 == 0:
		player1 = preload("res://characters/players/fire_man/scenes/FireMan.tscn").instance()
	elif p1 == 1:
		player1 = preload("res://characters/players/viking/scenes/Viking.tscn").instance()
	elif p1 == 2:
		player1 = preload("res://characters/players/spear_woman/scenes/SpearWoman.tscn").instance()
	
	if p2 == 0:
		player2 = preload("res://characters/players/fire_man/scenes/FireMan.tscn").instance()
	elif p2 == 1:
		player2 = preload("res://characters/players/viking/scenes/Viking.tscn").instance()
	elif p2 == 2:
		player2 = preload("res://characters/players/spear_woman/scenes/SpearWoman.tscn").instance()
	

	# Here we apply the different inputs for the players.
	InputController.set_j1_controls(player1)
	InputController.set_j2_controls(player2)
	
	add_child(player1)
	add_child(player2)
	
	
#
#	print(player1.move_right_input)
#	print(player1.move_left_input)
#	print(player1.crouch_input)
#	print(player1.jump_input)
#	print(player1.dash_input)
#	print(player1.primary_attack_input)
#	print(player1.secondary_attack_input)
#	print(player1.ultimate_attack_input)
#	print(player1.block_input)
#	print(player1.transform_input)
#	print(player1.run_input)
#
#	print(player2.move_right_input)
#	print(player2.move_left_input)
#	print(player2.crouch_input)
#	print(player2.jump_input)
#	print(player2.dash_input)
#	print(player2.primary_attack_input)
#	print(player2.secondary_attack_input)
#	print(player2.ultimate_attack_input)
#	print(player2.block_input)
#	print(player2.transform_input)
#	print(player2.run_input)
#

	player1.position = spawnp1.position
	player2.position = spawnp2.position
	
	var gui = player_gui.instance()

	get_tree().get_current_scene().add_child(gui)

func unlock_player_abilities():
	GAME.dash_unlocked = true
	GAME.spell_unlocked = true
	GAME.transform_unlocked = true
	GAME.ultimate_unlocked = true
