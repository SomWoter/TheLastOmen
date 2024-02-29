class_name Stomp
extends Area2D

##############################  NODE REFERENCE  ################################
onready var stomp = $"."
onready var sprite = $Sprite
onready var animation = $Animation
onready var left_spikes = $LeftSpikes
onready var right_spikes = $RightSpikes
#############################  SCENE REFERENCE  ################################

###############################  VARIABLES  ####################################
	#The damage the stomp spikes will do to the bodies
var damage : int
# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("stomp")

func _on_StompParanoia_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		body.damage_ctrl(damage)


# warning-ignore:unused_argument
func _on_Animation_animation_finished(anim_name):
	queue_free()
