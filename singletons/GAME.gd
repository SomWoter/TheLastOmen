"""SINGLETON USED IN ORDER TO MANAGE THE GAME"""
class_name Game
extends Node

var file_root : String = OS.get_user_data_dir().plus_file("tlo-saved.json")

var data
var id_user
var id_game = id_user
#var can_load : bool = false
# File root where the JSON saving file will be saved
var username : String
# Variable that stores the username of the user that was logged when the game was created.
var selected_character : String

var characters : Dictionary = {
	"Viking":
		"res://characters/players/viking/scenes/Viking.tscn",
	"SpearWoman":
		"res://characters/players/spear_woman/scenes/SpearWoman.tscn",
	"Fireman":
		"res://characters/players/fire_man/scenes/FireMan.tscn"
}
# Variable that stores the character scene path selected back on the Character Select Screen
export var spell_unlocked : bool
export var dash_unlocked : bool
export var transform_unlocked : bool
export var ultimate_unlocked : bool

var score : int
# Variable that stores the player gets along the gameplay, by collecting coins and killing different enemies.
var coins : int
# Variables used in order to store the amount of coins the player has already collected
var mobs_killed : int
# Variable that stores the amount of enemies the player kills along the gameplay.
var checkpoint : bool
#Variable that checks if the player has interacted with a checkpoint.
var test_level_list : Dictionary = {
	0: 
		"res://worlds/levels/TestLevel1.tscn",
	1: 
		"res://worlds/levels/TestLevel2.tscn",
	2:
		"res://worlds/levels/TestLevel3.tscn",
	3:
		"res://worlds/levels/FinalBossTestLevel.tscn",
}
var current_level_index : int
#Index of the current_level
var current_level
# Variable that stores the path of the scene of the level which the player is about to play. This value will change,
# when requiered, like once the player reaches a certain point in the level.
var current_pos : Vector2
# Variable that stores the position the player has in the level. By default, this value will be determined by the position 
# of a spawn point along the level, where the player will appear. This value will be overwritten once the player hits a checkpoint,
# where all the data will be saved.
var level_list : Dictionary = {
	0: 
		"res://worlds/levels/OakLevel1.tscn",
	1: 
		"res://worlds/levels/OakLevel2.tscn",
	2:
		"res://worlds/levels/OakLevel3.tscn",
	3:
		"res://worlds/levels/SwampLevel1.tscn",
	4:
		"res://worlds/levels/SwampLevel2.tscn",
	5:
		"res://worlds/levels/SwampLevel3.tscn",
	6:
		"res://worlds/levels/DessertLevel1.tscn",
	7:
		"res://worlds/levels/DessertLevel2.tscn", 
	8:
		"res://worlds/levels/DessertLevel3.tscn"
}

export var game_mode : String
export var dialog_shown : bool = false
# List that stores the scenes of all the different levels we want out stroy to have. 

#Function that will be called by the level end area in order to change of level.
func advance_level():
	checkpoint = false
	##First we need to check the last level we were, by getting the key of the value 
	# asigned to the current_level
	current_level_index = get_level_index(current_level)
	current_level_index += 1
	current_level = level_list.get(current_level_index)
	if current_level_index >= level_list.size():
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://gui/screens/credits/scenes/credits.tscn")
		delete_game(file_root)
	else:
		save_game()
		load_game()
## Function that retrieves the key of the value passed as a parameter.
#  @param : string value of the actual current level of GAME.current_level
# warning-ignore:unused_argument
func get_level_index(value : String) -> int:
	var level_index : int
	for key in level_list.keys():
		if level_list[key] == current_level:
			level_index = key
	return level_index
# Creates the JSON file using some predefined values for the level.
func create_game():
	#Default values for some data
	#All abilities are locked
	spell_unlocked = false
	dash_unlocked = false
	transform_unlocked = false
	ultimate_unlocked = false
	score = 0
	coins = 0
	mobs_killed = 0
	current_level_index = level_list.keys()[0]
	checkpoint = false
	save_game()
	load_game()

# Reads the values of the singleton variables and store them in the JSON file.
func save_game():
	data = {
		#"username" : username,
		"id_user" : id_user,
		"id_game" : id_game,
		"selected_character" : selected_character,
		"spell_unlocked" : spell_unlocked,
		"dash_unlocked" : dash_unlocked,
		"transform_unlocked" : transform_unlocked,
		"ultimate_unlocked" : ultimate_unlocked,
		"score" : score,
		"coins" : coins,
		"mobs_killed" : mobs_killed, 
		"current_level" : level_list.get(current_level_index),
		"checkpoint" : checkpoint,
		"current_pos" : [current_pos.x, current_pos.y]
	}

	if username != "guest":
		print("Id user is : " , GAME.id_user)
		GameServer.SavePlayerData(GAME.data)
	else:
		# We create the JSON file in order to save the data of the game.
		var file = File.new()
		file.open(file_root, File.WRITE)
		var json = to_json(data)
		file.store_line(json)
		file.close()

func load_game():
	print("load_game username is: " , username)
	if username != "guest":
		GameServer.LoadPlayerData()
		yield(get_tree().create_timer(3), "timeout")
		if data != null:
			if !data.size() > 0:
				print("\n == data < 0 user in game is: \n", data)
				print("Data.id_user ?? " , data.id_user)
				username = data.username
				id_user = data.id_user
				id_game = data.id_user
				selected_character = data.selected_character
				spell_unlocked = data.spell_unlocked
				dash_unlocked = data.dash_unlocked
				transform_unlocked = data.transform_unlocked
				ultimate_unlocked = data.ultimate_unlocked
				score = data.score
				coins = data.coins
				mobs_killed = data.mobs_killed
				current_level = data.current_level
				checkpoint = data.checkpoint
				current_pos = Vector2(data.current_posx, data.current_posy)
				print("\n CURRENT POSITION SHOULD BE: " , current_pos)
			else:
				print("\n == LOGGED data user in game is: \n", data)
				print("Data.id_user ?? " , data[0].id_user)
				username = data[0].username
				id_user = data[0].id_user
				id_game = data[0].id_user
				selected_character = data[0].selected_character
				spell_unlocked = data[0].spell_unlocked
				dash_unlocked = data[0].dash_unlocked
				transform_unlocked = data[0].transform_unlocked
				ultimate_unlocked = data[0].ultimate_unlocked
				score = data[0].score
				coins = data[0].coins
				mobs_killed = data[0].mobs_killed
				current_level = data[0].current_level
				checkpoint = data[0].checkpoint
				current_pos = Vector2(data[0].current_posx, data[0].current_posy)
				print("\n CURRENT POSITION SHOULD BE: " , current_pos)
# warning-ignore:return_value_discarded
			get_tree().change_scene(current_level)
	else:
		var file = File.new()
		#If there is no file to load.
		file.open(file_root, File.READ)
		data = parse_json(file.get_as_text())
		file.close()
		
	# And we load the JSON data to the variables
		if data != null:
			print("\n == DATA IN GAME IS: \n", data)
			selected_character = data.selected_character
			spell_unlocked = data.spell_unlocked
			dash_unlocked = data.dash_unlocked
			transform_unlocked = data.transform_unlocked
			ultimate_unlocked = data.ultimate_unlocked
			score = data.score
			coins = data.coins
			mobs_killed = data.mobs_killed
			print("Current_level: " , current_level, " data.current_level: " , data.current_level)
			current_level = data.current_level
			checkpoint = data.checkpoint
			current_pos = Vector2(data.current_pos[0], data.current_pos[1])
			print("\n CURRENT POSITION SHOULD BE: " , current_pos)
# warning-ignore:return_value_discarded
			get_tree().change_scene(current_level)

#Checks if there is an existant JSON File and deletes it if it's found.
# warning-ignore:shadowed_variable
func delete_game(file_root : String):
	if username == "guest":
		var file = File.new()
		if file.file_exists(file_root):
# warning-ignore:return_value_discarded
			OS.move_to_trash(file_root)
		file.close()
	else:
		print("SAVE SCORE ======================")
		GameServer.get_Check_HighScore_Player()
		yield(get_tree().create_timer(2.5), "timeout")
