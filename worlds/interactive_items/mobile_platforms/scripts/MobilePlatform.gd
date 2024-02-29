class_name MPlatform
extends Node2D

onready var animator = $PlatformAnimator

export(String, "Positive", "Negative") var direction
export(String, "Vertical", "Horizontal") var orientation

# Called when the node enters the scene tree for the first time.
func _ready():
	if direction == "Positive" and orientation == "Vertical":
		animator.play("positive_vertical")
	elif direction == "Positive" and orientation == "Horizontal":
		animator.play("positive_horizontal")
	elif direction == "Negative" and orientation == "Vertical":
		animator.play("negative_vertical")
	elif direction == "Negative" and orientation == "Horizontal":
		animator.play("negative_horizontal")

