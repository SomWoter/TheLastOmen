class_name MiniOmiSpawn
extends Position2D

##############################  NODE REFERENCE  ################################
onready var mini_omi_spawn = $"."
onready var sprite = $Sprite
onready var animation = $Animation
############################## SCENE REFERENCES ################################
var mob_to_spawn = preload("res://characters/enemies/final_boss/giga-omi/scenes/MiniOmi.tscn")
################################## VARIABLE ####################################
export var active : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if active:
		animation.play("open_portal")
	else:
		visible = false

## Function that will spawn Miniomis each time the timer timeouts.
func spawn_mini_omi():
	if active:
		var mini_omi = mob_to_spawn.instance()
		mini_omi.global_position = global_position
		get_parent().add_child(mini_omi)
		print("MINI OMI SPAWNED!")
