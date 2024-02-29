class_name PlayerCamera
extends Camera2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	position = player.position
	offset_v = -1.5
func _process(_delta):
	global_position.x = player.global_position.x
#	global_position.y = player.global_position.y
