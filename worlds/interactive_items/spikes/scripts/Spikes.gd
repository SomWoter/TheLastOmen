class_name Spikes
extends Area2D

var damage = 10

func _on_Danger_body_entered(body):
	if body is Fireman or body is SpearWoman or body is Viking:
		damage = body.max_health
		body.damage_ctrl(damage)
