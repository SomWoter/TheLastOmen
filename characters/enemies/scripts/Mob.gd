class_name Mob
extends KinematicBody2D

##############################  NODE REFERENCE  ################################

#############################  SCENE REFERENCE  ################################

###############################  VARIABLES  ####################################
var mob_name : String
var max_health : int
var health : int
var shield_max_health : int
var shield_health : int
var SPEED : int
var GRAVITY : int
var casted_spell : Resource

onready var motion : Vector2 = Vector2.ZERO
onready var direction : int = 1
###########################  BOOLEAN STATE VARIABLES  ##########################
onready var can_move : bool
var mob_score : int ##The punctuation obtained by the player once he kills the mob
################################  CONSTANTS ####################################
const FLOOR = Vector2(0, -1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	movement_ctrl()
	attack_ctrl()
	
## Function that controls the movement of the pertinent mob. Depending of the mob, 
# certain speed will be applied on ready and some others will be stopped until the 
# player gets in the detection area. This functions makes that, if the mob has no floor below him a
# little bit forward the direction he is facing, he automatically turns around. 
# Moreover, if the collides with a wall, the direction will also be corrected and 
# will start walking towards the other direction.
func movement_ctrl():
	pass
	
## Function that makes the mob turn around depending on certain circumstances, like
# when it collides with a wall or he runs out of walkable floor.
func direction_ctrl():
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
