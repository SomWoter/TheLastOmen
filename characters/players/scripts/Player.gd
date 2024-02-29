#############################  CLASS NAME  #####################################
#Line in order to test if GIT works properly
""" Here we set the class name of the Script and the node that extends"""
class_name Player
extends KinematicBody2D
##########################  NODE REFERENCES ####################################
onready var player = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var animation = $Animation
onready var animation_tree = $AnimationTree
onready var dust = $Particles/Dust
onready var dash_trail = $Particles/DashTrail

onready var sounds = $Sounds
onready var attack1_sound = $Sounds/Attack1
onready var attack2_sound = $Sounds/Attack2
onready var attack3_sound = $Sounds/Attack3
onready var attack1_effect_sound = $Sounds/Attack1_Effect
onready var attack2_effect_sound = $Sounds/Attack2_Effect
onready var attack3_effect_sound = $Sounds/Attack3_Effect
onready var jump_sound = $Sounds/Jump
onready var hit_sound = $Sounds/Hit
onready var death_sound = $Sounds/Death
onready var run_sound = $Sounds/Run
onready var dash_sound = $Sounds/Dash
onready var transform_sound = $Sounds/Transform
onready var spell_sound = $Sounds/Spell

onready var wall_raycast = $Raycasts/WallRaycast

onready var coyote_time = $Timers/CoyoteTime
onready var timer = $Timers/PlatformTimer
onready var crouch_timer = $Timers/CrouchTimer
onready var inmunity_timer = $Timers/InmunityTimer
onready var dash_timer = $Timers/Dash
onready var dash_cd_timer = $Timers/DashCooldownTimer
onready var transform_timer = $Timers/TransformTimer
onready var transform_cd_timer = $Timers/TransformCooldownTimer

onready var attack_area = $AttackArea
onready var attack_collision = $AttackArea/AttackCollision

onready var spell_spawn = $SpellSpawn
############################  SCENE REFERENCES #################################
""" Here we save in variables all the references to other scenes of the game"""
export var casted_spell : Resource
###############################  CONSTANTS  ####################################
""" Data that will never be modified neither by the user nor by any element in game"""
var WALK_SPEED : int = 150
var MAX_SPEED : int = 350
var DASH_SPEED : int = MAX_SPEED * 4 
const FLOOR = Vector2(0, -1)
var GRAVITY : int  = 50
var JUMP_HEIGHT : int  = 800
var BOUNCING_JUMP : int  = 500
var CAST_WALL : int  = 10
const MAX_JUMPS : int = 2
var max_wall_jumps : int = 1
var EJECTION_FORCE : int
###############################  STATS VARIABLES  ##############################
""" Here we have all the variables related about the statistics of the player, like
the damage it does depending of the attack, its health point amount, special points amount and 
the amount of elemental """
""" STATE MACHINE """
var playback : AnimationNodeStateMachinePlayback
#Health
export var max_health : int
var health : int
#Special 
export var max_special : int
var special : int
#Elemental power
export var max_elemental : int
var elemental : int
#This variable is used to count the jumps the player has done. The maximum is two, set by max_jumps. 
var jump : int
#This is the vector we use in order to set the movement for the player. 
onready var motion = Vector2.ZERO
#Attack and Deffense
export var attack_damage : int = 20
export var ultimate_damage: int = 40
###############################  BOOLEAN VARIABLES #############################
#Transformation controller. On default, the player is without the effect.
var transformed : bool = false
#Inmunity controller. Set on false by default in order to make the player able to take damage since the begining.
var inmunity : bool = false
var blocking : bool = false
var can_dash : bool = true
var dashing : bool

#Booleans that unlock certain abilities for the player
var spell_unlocked : bool
var dash_unlocked : bool
var transform_unlocked : bool
var ultimate_unlocked : bool

################################ INPUT VARIABLES ###############################
export var move_right_input : String 
export var move_left_input : String
export var crouch_input : String
export var jump_input : String
export var run_input : String
export var dash_input : String
export var primary_attack_input : String
export var secondary_attack_input : String
export var ultimate_attack_input : String
export var transform_input: String
export var block_input: String
##################################  FUNCTIONS  #################################
func _ready():
	playback = animation_tree.get("parameters/playback") #We get the reference to the playback parameter
	playback.start("idle")
	animation_tree.active = true
	
func _process(_delta):
	motion_ctrl()
	jump_ctrl()
	dash_ctrl()
	attack_ctrl()
	blocking_ctrl()
	spell_ctrl()
	ultimate_ctrl()
	transform_ctrl()
	
#By using the function get_axis, we are allowed to value the input from the user and set the direction of the player through it.
func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed(move_right_input)) - int(Input.is_action_pressed(move_left_input))
	return axis
	
#Blocks horizontal movement
func block_horizontal_movement():
	motion.x = 0
func manage_animation_states():
	#In this match, depending of the animations related to the horizontal movement, we activate certain.
	# parameters. When the animation is idle, which means the player is not moving, the Particles2D node
	# that simule dust is disabled, because they will appear only if the character is moving.
	match playback.get_current_node():
		"idle", "idle_effect":
			dust.emitting = false
		"walk", "walk_effect":
			dust.emitting = false
		"run", "run_effect":
			dust.emitting = true
			dash_trail.emitting = false
		"braking", "braking_effect":
			dust.emitting = false
			motion.x = lerp(motion.x, 0, 0.2)
		"jump", "jump_to_fall", "fall", "jump_effect", "jump_to_fall_effect", "fall_effect":
			dust.emitting = false
		#Animations where we want to lock the character position until these animations are finished.
		"crouch", "crouch_effect", "stay_crouched", "stay_crouched_effect":
			dust.emitting = false
		"hit", "hit_effect":
			block_horizontal_movement()
		"death", "death_effect", "dead":
			block_horizontal_movement()
			dust.emitting = false
		"attack1", "attack1_effect", "attack2", "attack2_effect", "attack3", "attack3_effect":
			block_horizontal_movement()
			dust.emitting = false
		"attack_crouched", "attack_crouched_effect":
			block_horizontal_movement()
			dust.emitting = false
		"attack_jump", "attack_jump_effect":
			dust.emitting = false
		"spell", "spell_effect":
			block_horizontal_movement()
			dust.emitting = false
		"ultimate", "ultimate_effect":
			block_horizontal_movement()
		"idle_block", "idle_block_effect", "block", "block_effect":
			block_horizontal_movement()
		"transform", "detransform":
			block_horizontal_movement()
#By using the funcion motion_ctrl, we have whole control on the horizontal movement of the player, by
# setting the animations using the AnimationTree node, flipping the Sprite Node depending on the direction he is facing, 
# activating the particles and activating and deactivating the different hitboxes the player have.
"""DONE"""
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
#				print("FRENAZO DE FUEGO!")
				playback.travel("braking_effect")
			elif !transformed and !Input.is_action_pressed(crouch_input):
#				print("FRENAZO!")
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

""" DONE, SO SIMPLE BEHAVIOR"""
#The function orientation control is used in order to flip all the child nodes to the opposing direction
# in depending of the direction the sprite is facing. The Player orientation_ctrl() function is developed in 
# order to suit with Fireman character, so there will be no need to override it in Fireman class.
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
#			sprite.position.x = -15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = -1
			
		false:
			wall_raycast.cast_to.x = CAST_WALL
			attack_area.scale.x = 1
			spell_spawn.scale.x = 1
			spell_spawn.position.x = 30
#			sprite.position.x = 15
			hitbox.position.x *= -1
			#Dash trail
			dash_trail.scale.x = 1
	
""" DONE, TEST CASES REMAINING """
#By using the jump_ctrl function, we are allowed to manage the states and the performance when the user
# presses jump. If the player is touching the floor, we set the jumps the player can perform according
# to the value of MAX_JUMPS, set in the sprint, and the raycast used to perform wall jumps remains disabled.
# If it is not, meaning the player already performed a jump or is falling, we stop the emission of the partibles
# and enable the raycast, so we can detect walls. We also set the animation jumps, so if the vertical motion 
# is negative, that means HE IS JUMPING. If is positive, means he is falling.

#Moreover, if the player has jumps remaining, and presses the jump button, will make a call to jump_event, 
# and will substract 1 to the variable that count the remaining jumps. 
#On the other hand, if the player has no remaining jumps, the raycast stores the body collided in
# a variable and then start the coyote time, that allows the player to perform a wall jump, that 
#applies to the vertical motion the same height of a current jump and the BOUNCE_JUMP to the horizontal 
# motion. 

func jump_ctrl():
	#If the player is touching the floor...
	match is_on_floor():
		true:
			jump = MAX_JUMPS
			wall_raycast.enabled = false
			if health <= 0 and (playback.get_current_node() != "death" or playback.get_current_node() != "death_effect"):
				if transformed:
					playback.travel("death_effect")
				else:
					playback.travel("death")
		false:
			wall_raycast.enabled = true
			if health > 0:
				if motion.y < 0:
					if transformed:
						playback.travel("jump_effect")
					else:
						playback.travel("jump")
				elif motion.y == 0:
					if transformed:
						playback.travel("jump_to_fall_effect")
					else:
						playback.travel("jump_to_fall")
				else:
					if transformed:
						playback.travel("fall_effect")
					else:
						playback.travel("fall")
			else:
				motion.y += 2 * GRAVITY
				block_horizontal_movement()
	if jump > 0:
		#Double Jump functionality
		if Input.is_action_just_pressed(jump_input):
#			if jump == 2:
##				print("First jump performed!")
#			elif jump == 1:
##				print("Second jump performed!")
			jump_event()
			jump -= 1
		
	#After the player is done performing the double jump because he can out of ramaining jumps...
	else:
		if wall_raycast.is_colliding():
			var body = wall_raycast.get_collider()
			if max_wall_jumps > 0 and body.is_in_group("Wall"):
				coyote_time.start()
		if coyote_time.time_left > 0 and Input.is_action_just_pressed(jump_input):
			match sprite.flip_h:
				true:
#					print("Horizontal force applied to the right!")
					motion.x += BOUNCING_JUMP
					jump_event()
				false:
#					print("Horizontal force applied to the left !")
					motion.x -= BOUNCING_JUMP
					jump_event()
#			print("WALL JUMP PERFORMED!")
			max_wall_jumps -= 1

""" DONE """
func jump_event():
	if health > 0:
		 #When the jump is performed, we substract one to the jump left counter we have
		match playback.get_current_node():
			"idle", "run", "braking", "walk", "idle_effect", "run_effect", "braking_effect", "walk_effect":
				motion.y -= JUMP_HEIGHT
			"jump", "jump_to_fall", "fall", "jump_effect", "jump_to_fall_effect", "fall_effect":
				#This will be the power of the second jump
				motion.y -= JUMP_HEIGHT

"""CROUCH COMEPLETELY DONE, SLIDE OMITTED"""
#The crouch controll function will allow the player many things. 
#If the player is in idle or walkin, he will crouch, what will stop its movement.
#If the player is running, he will perform a slide that will downgrade the speed movement until he stops. Once the animation is finished, 
# will go back to idle. 
#If the player is falling and then press crouch, if it has horizontal motion once he reaches the floor will reproduce slide animation. 
#If it is not, then will start the crouch animation. 
#Besides, here we have to prepare the controll that if the player presses twice between a timer on a platform, the collision will disable and go through it. 
func crouch_ctrl():
	if health > 0:
		if Input.is_action_just_pressed(crouch_input):
			crouch_timer.start()
			if transformed:
				playback.travel("crouch_effect")
			else:
				playback.travel("crouch")
			motion.x = 0
#			print("Start crouching")
		#If the player just released the crouch action button and he stills pressing the move button, I need to block the movement so he can't get below
		# low ground elements
		if Input.is_action_pressed(crouch_input):
			if transformed:
				playback.travel("stay_crouched_effect")
			else:
				playback.travel("stay_crouched")
			block_horizontal_movement()
			
		if crouch_timer.time_left > 0 and (Input.is_action_pressed(move_left_input) or Input.is_action_pressed(move_right_input)):
			block_horizontal_movement()
#Function that allows the player to perform a dash from IDLE, WALK, RUN, JUMP, JTF, FALL, BRAKING.
func dash_ctrl():
	dash_unlocked = GAME.dash_unlocked
	if dash_unlocked and health > 0:
		match playback.get_current_node():
			"walk", "walk_effect", "jump", "jump_effect", "jump_to_fall", "jump_to_fall_effect", "fall", "fall_effect":
				if can_dash and Input.is_action_just_pressed(dash_input) and get_axis().x != 0:
					dashing = true
					can_dash = false
					if transformed:
						playback.travel("dash_effect")
					else:
						playback.travel("dash")
					dash_sound.play()
					dash_timer.start()
""" IN DEVELOPMENT"""
#Using the attack control function we manage the inputs the user have to use in order to make the player attack.
#If the player is touching the floor in IDLE and presses the primary attack action button, it will
# perform a combo depending of the animation playback.
# On the other hand, if the player is jumping or mid air, will be able to perform a attack while jumping.
# Moreover, if the player is crouched, he will be able to perform a crouch attack.
func attack_ctrl() -> void:
	if health > 0:
		#If the player is currently touching the floor
		if is_on_floor():
			#Code for PRIMARY ATTACK, which is a meelee attack
			if Input.is_action_just_pressed(primary_attack_input):
				match playback.get_current_node():
					#NORMAL PRIMARY ATTACK COMBO
					"idle","idle_effect", "walk", "run", "walk_effect", "run_effect", "braking", "braking_effect":
						if transformed:
							playback.travel("attack1_effect")
						else:
							playback.travel("attack1")
							attack1_sound.play()
#						print("ATTACK 1!")
					"attack1", "attack1_effect":
						if transformed:
							playback.travel("attack2_effect")
							attack2_effect_sound.play()
						else:
							playback.travel("attack2")
							attack2_sound.play()
#						print("ATTACK 2!")
					"attack2", "attack2_effect":
						if transformed:
							playback.travel("attack3_effect")
							attack3_effect_sound.play()
						else:
							playback.travel("attack3")
							attack3_sound.play()
#						print("ATTACK 3!")
					"crouch", "crouch_effect", "stay_crouched_effect","stay_crouched":
						if transformed:
							playback.travel("attack_crouched_effect")
						else:
							playback.travel("attack_crouched")
#						print("ATTACK CROUCHED!")
		#If the player is midair
		elif !is_on_floor():
			if Input.is_action_just_pressed(primary_attack_input):
				match playback.get_current_node():
					"jump", "fall", "jump_to_fall", "jump_effect", "fall_effect", "jump_to_fall_effect":
						if transformed:
							playback.travel("attack_jump_effect")
#							print("FIRE JUMP ATTACK!")
						else:	
							playback.travel("attack_jump")
							attack2_sound.play()
#							print("JUMP ATTACK!")
	#	elif is_on_floor() and (playback.get_current_node() == "stay_crouched" or playback.get_current_node() == "crouch"):
	#		if Input.is_action_just_pressed("primary_attack"):
	#If the player is jumping or falling
"""IN DEVELOPMENT, BUT ALMOST DONE. JUST NEED TO APPLY A FEW DETAILS"""
#Function in order to manage the ability of the Player to cast a spell. Depending of the value of the mana
# bar of the player, he will be able to cast a spell, that will downgrade the value of the bar every single time
# it is used. The player has to be able to cancel the animation by moving, jumping or crouching. 
func spell_ctrl():
	spell_unlocked = GAME.spell_unlocked
	if spell_unlocked:
		if Input.is_action_just_pressed(secondary_attack_input) and (special > 0 or transformed) and health > 0:
			if transformed:
				playback.travel("spell_effect")
			else:
				playback.travel("spell")
	
func cast_spell():
	var spell = casted_spell.instance()
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	if transformed:
		spell.damage *= 3
#		spell.scale.x = 5
#		spell.scale.y = 5
	else:
#		spell.scale.x = 3
#		spell.scale.y = 3
		special -= 1
	match sprite.flip_h:
		true:
			spell.scale.x *= -1
			spell.direction = -spell.MOVEMENT_SPEED
		false:
			spell.scale.x *= 1
			spell.direction = spell.MOVEMENT_SPEED
#By using this function we allow the character to perform an ultimate once the elemental bar is completely full.
func ultimate_ctrl():
	ultimate_unlocked = GAME.ultimate_unlocked
	if ultimate_unlocked and health > 0:
		if Input.is_action_just_pressed(ultimate_attack_input) and is_on_floor()  and elemental == max_elemental:
			if transformed:
				playback.travel("ultimate_effect")
			elif !transformed and elemental == max_elemental:
				playback.travel("ultimate")
			elemental -= elemental
			transform_cd_timer.start()
func blocking_ctrl():
	if health > 0:
		if Input.is_action_pressed(block_input) and is_on_floor():
			#Meanwhile the character is on idle_block, he will be invulnerable to the attacks
			if transformed:
				playback.travel("idle_block_effect")
				blocking = true
			else:
				playback.travel("idle_block")
				blocking = true
		elif Input.is_action_just_released(block_input):
			blocking = false
			inmunity = false
#"""DONE"""
#Function made in order to manage the damage the player takes once takes damage. Called by the entities that 
# causes the damage to the player.
func damage_ctrl(damage_to_receive : int) -> void:
#	print("Damage took: ", damage_to_receive)
	#If the player can take damage...
	if !inmunity and health > 0 and damage_to_receive < health and !blocking:
		#If it's false, means that the Player have to get some damage
		health -= damage_to_receive
#		print("Life remaining: " , health)
#		print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
		if transformed:
			playback.travel("hit_effect")
		else:
			playback.travel("hit")
	#In case the attack damage the player is getting is higher than his remaining life, we will substract the 
	# value to get zero. THIS MEANS THE PLAYER IS GONNA DIE.
	elif damage_to_receive >= health or health <= 0:
		health -= health
		match is_on_floor():
			true:
				if transformed:
#					print("YOU DIED transformed")
					playback.travel("death_effect")
				else:
#					print("YOU DIED")
					playback.travel("death")
			false:
				block_horizontal_movement()
				motion.y += 2 * GRAVITY
"""IN DEVELOPMENT"""
#Function that manages the ability if transforming and untransforming. That will trigger the boolean variable
# transformed, that will change the other animations to the one that has the elemental effect on the player. 
func transform_ctrl():
	transform_unlocked = GAME.transform_unlocked
	if transform_unlocked and health > 0:
		match transformed:
			false:
				if Input.is_action_just_pressed(transform_input) and elemental == max_elemental:
					playback.travel("transform")
#					print("TE ACABAS DE TRANSFORMAR")
					transformed = true
					transform_timer.start()
			true:
				#If the player ran out of elemental power and is touching the ground
				if elemental <= 0 and is_on_floor():
					transform_timer.stop()
					playback.travel("detransform")
					transformed = false
					transform_cd_timer.start()
#func coins_ctrl():
#	var playerGUI = get_tree().get_root().find_node("PlayerGUI", true, false)
#	playerGUI.handle_picked_coins()

#Timer used in order to go through the platorms.
func _on_Timer_timeout():
	#Then the Timer time is over, then the hitboxes are ready to detect bodies again.
	hitbox.disabled = false

#This controls when a body enters the attack area
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

#When the dash ends...
func _on_Dash_timeout():
	#We're no longer dashing and we won't be able to perfrorm another dash in this time.
	dashing = false
	dash_cd_timer.start()
	
func _on_DashCooldownTimer_timeout():
	can_dash = true

##Signal connected in order to control when to pass from idle_block to block.
func _on_AttackArea_area_entered(area):
#	print("Area detected!")
	#If the body that owns that area attack is active, if part of the meelee attacks group and the collision shape of that area is active.
	#If the player is blocking 
	if blocking and area.is_in_group("Attack"):
		inmunity = true
		if transformed:
			playback.travel("block_effect")
		else:
			playback.travel("block")
	else:
		inmunity = false
#	if blocking:
#		#If the player belongs to the Attack group, which are the area2ds that are meelee attacks...
#		if area.is_in_group("Attack") and area.monitoring:
#			inmunity = true
#			if transformed:
#				playback.travel("block_effect")
#			else:
#				playback.travel("block")
#			blocking = false
#		elif !area.is_in_group("Attack"):
#			inmunity = false
##			print("NO PUEDES BLOQUEAR ATAQUES BAJOS NI HECHIZOS!")
#			blocking = false

#This will be the timer that will start when the player transforms. Meanwhile the elemental > 0, it 
# will substract 1 to the elemental value. This state will also let the character heal himself
func _on_TransformTimer_timeout():
	if elemental > 0:
#		print(health)
#		print(special)
#		print(elemental)
#		print(inmunity)
		elemental -= 1
		if health < max_health and health > 0:
			health += 5

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"transform":
			inmunity = false
			transform_timer.start()
		"detransform", "ultimate", "ultimate_effect":
			inmunity = false
			transform_cd_timer.start()

func _on_TransformCooldownTimer_timeout():
	#Only if the actual value of elemental is lower than the maximum...
	if elemental < max_elemental and !transformed:
#		print(health)
#		print(special)
#		print(elemental)
#		print(inmunity)
		transform_timer.stop()
		elemental += 1

func _on_Animation_animation_started(anim_name):
	match anim_name:
		"transform":
			inmunity = true
		"detransform":
			inmunity = true
		"ultimate", "ultimate_effect":
			inmunity = true
#		"idle_block", "idle_block_effect":
#			blocking = true

func _on_VisibilityNotifier_screen_exited():
	damage_ctrl(health)
