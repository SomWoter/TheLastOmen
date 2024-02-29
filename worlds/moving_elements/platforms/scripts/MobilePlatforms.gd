class_name MobilePlatform
extends Position2D
############################  SCENE REFERENCES #################################

###############################  CONSTANTS  ####################################


onready var platform_body = $MovingPlatform
onready var platform_animation = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _process(_delta):
	change_movement()
	
func change_movement():
	if platform_body.is_in_group("Horizontal Platform"):
		platform_animation.play("move_horizontally")
	elif platform_body.is_in_group("Vertical Platform"):
		platform_animation.play("move_vertically")
