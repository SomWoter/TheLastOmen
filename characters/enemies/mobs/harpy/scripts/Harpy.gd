class_name Harpy
extends Node2D

func _on_Area2D_body_entered(body):
	if body.has_method('change_state'):
		body.change_state()
