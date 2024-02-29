class_name NPC
extends Node2D
###############################  COMMON ATRIBUTES ##############################
onready var detection_area
		#Detection area might be an Area2D or a Raycast2D, that will determine the distance 
		# needed for the characters in order to interact with the characters.
var character_dialog
	#Dialog variable used to display the timelines
var active : bool = false
	#Variable that indicates when the dialog can be shown, like once the player gets close enough to the character.
var dialog_active : bool = false
	#Variable that tells if the dialog has already appeared in the scene tree.

# Called when the node enters the scene tree for the first time.
################################ COMMON METHODS ################################

#In the parent _ready function, we set the value of the value definitions generally needed to know 
# for most of the interactions in the dialogs.
func _ready():
	pass

#In the parent process we do nothing in particular. We will set the interact_ctrl function behavior
# in its children and the functions that triggers them.
func _process(delta):
	interact_ctrl()
	
# Function that manages the way the user/player interact with the different NPCS. 
# The behavior of this function will be conditioned by the variables active and dialog_active, 
# that determine if the player is in the range determined by an Area2D or a Raycast2D or if there's 
# already an opened dialog.
func interact_ctrl():
	pass
	
## Function that starts the dialog, the variables needed for the respective character timelines and 
# the signals needed. Called in the interact_ctrl() function by the NPC.
# @param timeline_name : the name of the dialog timeline we want to start
func start_dialog(timeline_name : String):
	character_dialog = Dialogic.start(timeline_name)
	character_dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(character_dialog)
	set_needed_definition_values()
	connect_needed_signals()
	GAME.dialog_shown = true
	get_tree().paused = true

func close_dialog(timeline_name : String):
	GAME.dialog_shown = false
	get_tree().paused = false

## Function called by the dialogic_signal emitted from the different character timelines.
# It gets as a parameter the one described in the timelines
# @param event_to_do the changes we wanna do in-game
func dialogic_signal_event(event_to_do : String):
	pass

## Function that sets the values needed for the course of the dialog timeline.
func set_needed_definition_values():
	pass

## Function that connects the emmited signals from the character timeline.
func connect_needed_signals():
	pass
