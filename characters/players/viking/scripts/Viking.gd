class_name Viking
extends Player

""" WE USE READY IN ORDER TO SET THE VALUE OF THE DIFFERENT VARIABLES WHOSE VALUE CHANGE DEPENDING
	OF THE CHARACTER SELECTED """
	
################################  SCENE REFERENCE  #############################
onready var ice_spike = preload("res://characters/players/viking/scenes/IceSpike.tscn")

func _ready():
	casted_spell = ice_spike
	max_health = 150
	health = max_health
	max_special = 20
	special = max_special
	max_elemental = 30
	elemental = max_elemental
	attack_damage = 20
	ultimate_damage = 750
	
func orientation_ctrl():
	match sprite.flip_h:
		true:
			#We flip the horizontal orientation of the Wall raycast
			wall_raycast.cast_to.x = -CAST_WALL
			#We flip the horizontal orientation of the attack area
			attack_area.scale.x = -1
			#We flip the horizontal orientation of the Spell spawn where teh spells will spawn from
			spell_spawn.scale.x = -1
			spell_spawn.position.x = -26.5
#			sprite.position.x = -15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = -1
		false:
			wall_raycast.cast_to.x = CAST_WALL
			attack_area.scale.x = 1
			
			spell_spawn.scale.x = 1
			spell_spawn.position.x = 26.5
#			sprite.position.x = 15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = 1

func dash_ctrl():
	dash_unlocked = GAME.dash_unlocked
	if dash_unlocked and health > 0:
		match playback.get_current_node():
			"walk", "walk_effect", "jump", "jump_effect", "jump_to_fall", "jump_to_fall_effect", "fall", "fall_effect":
				if can_dash and Input.is_action_just_pressed(dash_input) and get_axis().x != 0:
					dash_trail.position.x = -10
					dashing = true
					can_dash = false
					if transformed:
						dash_trail.texture = load("res://characters/players/viking/assets/viking_effect_dash_trail.png")
						playback.travel("dash_effect")
#						dash_trail.texture = 
					else:
						dash_trail.texture = load("res://characters/players/viking/assets/viking_dash_trail.png")
						playback.travel("dash")
#						dash_trail.texture = 
					dash_sound.play()
					dash_timer.start()

func cast_spell():
	var spell = casted_spell.instance()
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	if transformed:
		spell.MOVEMENT_SPEED *= 2
		spell.scale.x = 2
		spell.damage *= 2
		spell.scale.y = 2
	else:
		spell.scale.x = 2
		spell.scale.y = 2
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
					body.damage_ctrl(attack_damage * 10)
				else:
					body.damage_ctrl(attack_damage)
		#Alternative way to meelee attack
		"attack_jump", "attack_jump_effect", "attack_crouched", "attack_crouched_effect":
			if (body.is_in_group("Enemy") or body.is_in_group("Player")) and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(attack_damage * 10)
				else:
					body.damage_ctrl(attack_damage)
		#Ultimate, the most effective way the player has to hurt the enemies and other players
		"ultimate", "ultimate_effect":
			if body.is_in_group("Enemy") and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(ultimate_damage * 10)
				else:
					body.damage_ctrl(ultimate_damage)
