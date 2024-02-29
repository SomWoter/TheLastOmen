#############################  CLASS NAME  #####################################
class_name Spell
extends Area2D
##########################  NODE REFERENCES ####################################
onready var fireball = $"."
onready var sprite = $"Sprite"
onready var animation = $Animation
onready var hitbox = $Hitbox
onready var audio = $Travel
onready var visibility = $Visibility
###############################  CONSTANTS  ####################################
var MOVEMENT_SPEED : int = 500
###############################  STATS VARIABLES  ##############################
var direction : int
var vert_direction : int = 0
var damage : int = 30
###############################  BOOLEAN VARIABLES  ############################
onready var can_move : bool = true
##################################  FUNCTIONS  #################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("travel")
	audio.play()
	
func _process(delta) -> void:
#	motion.x = MOVEMENT_SPEED * delta * direction
	if can_move:
		global_position.x += direction * delta
		global_position.y += vert_direction * delta

#When the Fireball collides with something...
func _on_Fireball_body_entered(body):	
	if body.is_in_group("Enemy") or body.is_in_group("Player"):
		if body.has_method("damage_ctrl"):
			body.damage_ctrl(damage)
		animation.play("impact")
	
	elif body.is_in_group("Wall"):
		print("The fireball hit a wall or the terrain.")
		animation.play("impact")

	elif body.is_in_group("null"):
		print("The fireball hit something random")
		if body.has_method("damage_ctrl"):
			body.damage_ctrl(damage)
		animation.play("impact")

#If the Fireball reaches the end of the screen, it will disappear
func _on_Visibility_screen_exited():
	queue_free()

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"impact":
			queue_free()

func _on_Animation_animation_started(anim_name):
	match anim_name:
		"impact":
			can_move = false
