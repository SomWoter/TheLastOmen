class_name SpearWoman
extends Player

################################  SCENE REFERENCES  ############################
onready var light_ball = preload("res://characters/players/spear_woman/scenes/LightBall.tscn")

func _ready():
	casted_spell = light_ball
	max_health = 100
	health = max_health
	max_special = 25
	special = max_special
	max_elemental = 30
	elemental = max_elemental
	attack_damage = 20
	ultimate_damage = 500
func motion_ctrl() -> void:
	#We apply gravity to the body. If it's dashing, we'll change the value of the gravity.
	match dashing:
		#If the player is currently dashing...
		true:
		#Meanwhile the character is moving forward any horizontal direction
			#The dash speed will be
			if sprite.flip_h:
				motion.x = -DASH_SPEED
			else:
				motion.x = DASH_SPEED
			#We start emitting the dash trail
			dash_trail.emitting = true
			match playback.get_current_node():
				"dash", "dash_effect":
					#We remove the gravity pressure on the character
					motion.y = 0
		#If he is not currently dashing...
		false:
			if playback.get_current_node() == "ultimate" or playback.get_current_node() == "ultimate_effect":
				motion.y = 0
			else:
				#We apply the normal GRAVITY to the character
				motion.y += GRAVITY
				#Set the speed to WALK, unless the player decides to run
				motion.x = get_axis().x * WALK_SPEED
				dash_trail.emitting = false
			
	if Input.is_action_pressed(run_input):
		motion.x = get_axis().x * MAX_SPEED

	#If the player is neither pressing run_right or run_left, then means he is stop.
	#So we play the idle animation and set the player scale to the same as the last one he had
	if get_axis().x == 0 and health > 0:
		#If the player just released the button of moving and he is running or running transformes...
		if (Input.is_action_just_released(move_left_input) or Input.is_action_just_released(move_right_input)) and (playback.get_current_node() == "run" or playback.get_current_node() == "run_effect"):
			if transformed and !Input.is_action_pressed(crouch_input):
				print("FRENAZO DE FUEGO!")
				playback.travel("braking_effect")
			elif !transformed and !Input.is_action_pressed(crouch_input):
				print("FRENAZO!")
				playback.travel("braking")
		else:
			if transformed:
				playback.travel("idle_effect")
			else:
				playback.travel("idle")
#		player.scale.x *= 1
	#By other hand, if the player is pressing run_right, we set the run animation and we don't 
	# flip the sprite, cuz the original sprite is looking right.
	elif get_axis().x == 1 and health > 0:
		if motion.x == get_axis().x * WALK_SPEED:
			if transformed:
				playback.travel("walk_effect")
			else:
				playback.travel("walk")
			
		elif motion.x == get_axis().x * MAX_SPEED:
			if transformed:
				playback.travel("run_effect")
			else:
				playback.travel("run")
		sprite.flip_h = false
	#And finally, if the player is pressing run_left, we set the animation to run and then we 
	# flip the sprite, because we want the sprite to look left 
	elif get_axis().x == -1 and health > 0:
		if motion.x == get_axis().x * WALK_SPEED:
			if transformed:
				playback.travel("walk_effect")
			else:
				playback.travel("walk")
		elif motion.x == get_axis().x * MAX_SPEED:
			if transformed:
				playback.travel("run_effect")
			else:
				playback.travel("run")
		sprite.flip_h = true
	
	manage_animation_states()

	""" THIS GOES IN CROUCH_CTRL()"""
	crouch_ctrl()
	orientation_ctrl()
	motion = move_and_slide(motion, FLOOR)

	#The following code is made in order to be able to go through the normal and moving platforms when 

	# the player presses jump while crouched. We HAVE TO write it rigth after move and slide 
	var slide_count = get_slide_count() #Returns the number of times the body is colliding
	if slide_count:  #If it was >0 then would be true
		#We save the collision body in the collision variable 
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider

		#Now we have to see if the collided object is a platform, and then if the player do the 
		# correct inputs, the collision box will be disabled.

		if collider.is_in_group("Platform") and (Input.is_action_pressed(crouch_input) and Input.is_action_just_pressed(jump_input)):
			hitbox.disabled = true
			timer.start()
func orientation_ctrl():
	match sprite.flip_h:
		true:
			#We flip the horizontal orientation of the Wall raycast
			wall_raycast.cast_to.x = -CAST_WALL
			#We flip the horizontal orientation of the attack area
			attack_area.scale.x = -1
			#We flip the horizontal orientation of the Spell spawn where teh spells will spawn from
			spell_spawn.scale.x = -1
			spell_spawn.position.x = -37.333
			sprite.position.x = -8
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = -1
			
		false:
			wall_raycast.cast_to.x = CAST_WALL
			attack_area.scale.x = 1
			spell_spawn.scale.x = 1
			spell_spawn.position.x = 37.333
			sprite.position.x = 8
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = 1
			
func dash_ctrl():
	dash_unlocked = GAME.dash_unlocked
	if dash_unlocked and health > 0:
		match playback.get_current_node():
			"walk", "walk_effect", "jump", "jump_effect", "jump_to_fall", "jump_to_fall_effect", "fall", "fall_effect":
				if can_dash and Input.is_action_just_pressed(dash_input) and get_axis().x != 0:
					dash_trail.position.y = -17.75
					dashing = true
					can_dash = false
					if transformed:
						dash_trail.texture = load("res://characters/players/spear_woman/assets/spear_effect_dash_trail.png")
						playback.travel("dash_effect")
					else:
						dash_trail.texture = load("res://characters/players/spear_woman/assets/spear_dash_trail.png")
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
		spell.MOVEMENT_SPEED *= 2
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
			print("SUPRESSING GRAVITY!")
			if body.is_in_group("Enemy") and body.has_method("damage_ctrl"):
				if transformed:
					body.damage_ctrl(ultimate_damage * 10)
				else:
					body.damage_ctrl(ultimate_damage)
