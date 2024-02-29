class_name Fireman
extends Player
### NODE REFERENCE ###
onready var fireman = $"."
############################  SCENE REFERENCES #################################
onready var fire_ball = preload("res://characters/players/fire_man/scenes/Fireball.tscn")
###############################  STATS VARIABLES  ##############################
""" IN SCRIPT INHERITANCE IN GODOT, THE _ready FUNCTION OF THE PARENT IS ALWAYS EXECUTED """

""" PROCESS FUNCTION FOR THE FIREMAN SCENE. INHERITS SOME METHODS FROM THE SUPERCLASS PLAYER """
func _ready():
	casted_spell = fire_ball
	max_health = 100
	health = max_health
	max_special = 10
	special = max_special
	max_elemental = 10
	elemental = max_elemental
	attack_damage = 20
	ultimate_damage = 40
	
func orientation_ctrl():
	match sprite.flip_h:
		true:
			#We flip the horizontal orientation of the Wall raycast
			wall_raycast.cast_to.x = -CAST_WALL
			#We flip the horizontal orientation of the attack area
			attack_area.scale.x = -1
			#We flip the horizontal orientation of the Spell spawn where teh spells will spawn from
			spell_spawn.scale.x = -1
			spell_spawn.position.x = -30
			#We change the sprite position depending on the assets the character has in the case they are not centered
			sprite.position.x = -15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = -1
			
		false:
			wall_raycast.cast_to.x = CAST_WALL
			attack_area.scale.x = 1
			
			spell_spawn.scale.x = 1
			spell_spawn.position.x = 30
			sprite.position.x = 15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = 1
func dash_ctrl():
	dash_unlocked = GAME.dash_unlocked
	if dash_unlocked and health > 0:
		match playback.get_current_node():
			"walk", "walk_effect", "jump", "jump_effect", "jump_to_fall", "jump_to_fall_effect", "fall", "fall_effect":
				if can_dash and Input.is_action_just_pressed(dash_input) and get_axis().x != 0:
					dashing = true
					can_dash = false
					if transformed:
						dash_trail.texture = load("res://characters/players/fire_man/assets/fireman_effect_dash_trail.png")
						playback.travel("dash_effect")
						
					else:
						dash_trail.texture = load("res://characters/players/fire_man/assets/fireman_dash_trail.png")
						playback.travel("dash")
#						dash_trail.texture = 
					dash_sound.play()
					dash_timer.start()
func cast_spell():
	var spell = casted_spell.instance()
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	if transformed:
		spell.damage *= 3
		spell.scale.x = 5
		spell.scale.y = 5
	else:
		spell.scale.x = 3
		spell.scale.y = 3
		special -= 1
	match sprite.flip_h:
		true:
			spell.scale.x *= -1
			spell.direction = -spell.MOVEMENT_SPEED
		false:
			spell.scale.x *= 1
			spell.direction = spell.MOVEMENT_SPEED
func _on_AttackArea_body_entered(body):
	match playback.get_current_node():
		#Regular primary attack combo states
		"attack1", "attack1_effect", "attack2", "attack2_effect", "attack3", "attack3_effect":
			if (body.is_in_group("Enemy") or body.is_in_group("Player")) and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(attack_damage * 2)
				else:
					body.damage_ctrl(attack_damage)
		#Alternative way to meelee attack
		"attack_jump", "attack_jump_effect", "attack_crouched", "attack_crouched_effect":
			if (body.is_in_group("Enemy") or body.is_in_group("Player")) and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(attack_damage * 2)
				else:
					body.damage_ctrl(attack_damage)
		#Ultimate, the most effective way the player has to hurt the enemies and other players
		"ultimate", "ultimate_effect":
			if (body.is_in_group("Enemy") or body.is_in_group("Player")) and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(ultimate_damage * 1.5)
				else:
					body.damage_ctrl(ultimate_damage)
