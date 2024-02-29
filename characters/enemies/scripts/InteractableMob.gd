class_name InteractableMob
extends KinematicBody2D
##############################  NODE REFERENCE  ################################

#############################  SCENE REFERENCE  ################################

###############################  VARIABLES  ####################################
			#In order to be a mob
var mob_name : String
var mob_score : int ##Score obtained once you kill the mob
var max_health : int
var health : int
var shield_max_health : int
var shield_health : int
var SPEED : int
var GRAVITY : int
var casted_spell : Resource

export var attack_triggered : bool = false
onready var motion : Vector2 = Vector2.ZERO
onready var direction : int = 1

			#In order to make it able to speak
onready var detection_area
		#Detection area might be an Area2D or a Raycast2D, that will determine the distance 
		# needed for the characters in order to interact with the characters.
var character_dialog
	#Dialog variable used to display the timelines
var active : bool = false
	#Variable that indicates when the dialog can be shown, like once the player gets close enough to the character.
var dialog_active : bool = false
	#Variable that tells if the dialog has already appeared in the scene tree.
###########################  BOOLEAN STATE VARIABLES  ##########################
onready var can_move : bool
################################  CONSTANTS ####################################
const FLOOR = Vector2(0, -1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	movement_ctrl()
	if attack_triggered:
		attack_ctrl()
	interact_ctrl()
	
## Function that controls the movement of the pertinent mob. Depending of the mob, 
# certain speed will be applied on ready and some others will be stopped until the 
# player gets in the detection area. This functions makes that, if the mob has no floor below him a
# little bit forward the direction he is facing, he automatically turns around. 
# Moreover, if the collides with a wall, the direction will also be corrected and 
# will start walking towards the other direction.
func movement_ctrl():
	pass
	
## Function that controls when the mob takes damage, called by the attacking body. 
# If the health attribute value of the mob reaches 0, some death animation will 
# be played. Depending of the child of Mob, they will be able to instant take 
# damage once the attacking body calls the function.
# @param damage_to_receive: the integer value we want to substract from the mob 
# current health
# warning-ignore:unused_argument
func damage_ctrl(damage_to_receive : int):
	pass
	
## Function triggered once the player to be attacked enters an area delimited by an 
# Area2D node or a Raycast 2D. This function will play the needed animation in order to play
# the different attacks the player has.
func attack_ctrl():
	pass

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

# warning-ignore:unused_argument
func close_dialog(timeline_name : String):
	GAME.dialog_shown = false
	get_tree().paused = false
## Function called by the dialogic_signal emitted from the different character timelines.
# It gets as a parameter the one described in the timelines
# @param event_to_do the changes we wanna do in-game
# warning-ignore:unused_argument
func dialogic_signal_event(event_to_do : String):
	pass

## Function that sets the values needed for the course of the dialog timeline.
func set_needed_definition_values():
	pass

## Function that connects the emmited signals from the character timeline.
func connect_needed_signals():
	pass

