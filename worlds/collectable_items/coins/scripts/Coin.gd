class_name Coin
extends Area2D

##########################  NODE REFERENCES ####################################
onready var coin = $"."
onready var sprite = $Sprite
onready var audio = $Audio
onready var hitbox = $Hitbox
onready var animation = $AnimationPlayer
############################  SCENE REFERENCES #################################

#################################  SIGNALS  ####################################

#onready var playerGUI : CanvasLayer = get_tree().get_nodes_in_group("PlayerGUI")[0]
export(String, "Coin", "Chest", "Rune") var type : String
onready var active : bool = true

func _ready() -> void:
	animation.play("idle")
	
func _on_Coin2D_body_entered(body) -> void:
	if body.is_in_group("Player"):
		GAME.coins += 1
		GAME.score += 25
		audio.play()
		animation.play("picked")

func _on_AnimationPlayer_animation_started(anim_name) -> void:
	match anim_name:
		"picked":
			if active:
				audio.play()
				active = false

func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	match anim_name:
		"picked":
			queue_free()
