extends Node


var character_p1
var character_p2
var char_nump1
var char_nump2


# Variable that stores the number of vitories of each player
var wins_p1 = 0
var wins_p2 = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func load_p1():
#	print(character_p1)
	return str(character_p1)
	
func load_p2():
#	print(character_p2)
	return str(character_p2)
	
func load_num():
	return  char_nump1
	
func load_num2():
	return  char_nump2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
