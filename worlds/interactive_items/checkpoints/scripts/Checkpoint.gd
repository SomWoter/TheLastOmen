#############################  CLASS NAME  #####################################
class_name Checkpoint
extends Area2D
##########################  NODE REFERENCES ####################################
#onready var world = get_tree().get_root().find_node("World", true, false)
############################  SCENE REFERENCES #################################
onready var checkpoint = $"."
onready var sprite = $Sprite
onready var animation = $Animation
onready var audio = $Audio
onready var hitbox = $Hitbox

#Variable used in order to show if the checkpoint has been used already
var active : bool = true

func _ready():
	animation.play("idle")
#
func _on_Checkpoint2D_body_entered(body):
	if active:
		if body.is_in_group("Player"):
			animation.play("check")
			audio.play()
			GAME.current_pos = global_position
			GAME.checkpoint = true
			GAME.save_game()

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"check":
			animation.play("checked")


func _on_Animation_animation_started(anim_name):
	match anim_name:
		"check":
			active = false
#
#
#func _on_Obelisk_body_entered(body):
#	if active:
#		if body.is_in_group("Player"):
#			animation.play("check")
#			audio.play()
#			GAME.current_pos = global_position
#			GAME.checkpoint = true
#			GAME.save_game()
