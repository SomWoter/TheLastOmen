class_name Minotaur
extends KinematicBody2D

onready var state_machine = $AnimationTree.get('parameters/playback')
onready var animationPlayer = $AnimationPlayer
onready var health_bar = $Health_bar
onready var raycast_detech_player_behind = $raycast_detech_player_behind
onready var raycast_detech_player_towards = $raycast_detech_player_towards
onready var raycast_detech_floor = $raycast_detech_floor
onready var raycast_detech_wall = $raycast_detech_wall

var group_player = "Player"

export var SPEED = 50
export var health = 2000
export var attack_melee_daamge = 10
export var attack_ground_damage = 30
export var inmune_damage = 5

const mob_score = 1000

var speed = SPEED
var default_speed = SPEED
var velocity = Vector2(speed, 0)
var UP = Vector2(0, -1)
var gravity = 700

# TEST FUNCTION ONLY
var hit = 10

var turned_side = false
var dead = false

onready var end_area : LevelEnd = get_tree().get_nodes_in_group("End")[0]

func _ready():
	set_animation_movement()
	health_bar.value = health
	health_bar.max_value = health
	end_area.active = false

# warning-ignore:unused_argument
func _physics_process(delta):
	velocity.y += gravity
	# If is alive	
	if health > 0:	
			# Play the correct animation
			set_animation_movement()
			# If ->next to him isn't floor, he is on floor, there is a wall next to him, is alive, there isn't any player
			# or there isn't any player behind
			if !_detech_floor() and is_on_floor() or _detech_wall() and health > 0 and !detech_player_towards() or raycast_detech_player_behind():
				# FLIP direction
				change_state()
			# IF there is a player in front
			if detech_player_towards():
				pass
	else:
		# If is not alive, dies
		state_machine.travel("Dead")
		end_area.active = true
		return
	# Apllies the velocity and gravity
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

# Method for receiving damgage from other body
func damage_ctrl(damage):
	# If is alive
	if health > 0:
		# if the damage is higher than @inmune_damage
		if damage > inmune_damage:
			# Play animation of hit
			state_machine.travel('Hit')
			# Receive the damage to the health
			health -= damage
			# Refresh health bar value
			health_bar.value = health
		
"""AÑADIDO POR ADRI PARA PRUEBA DE CAMBIO DE NIVEL"""
func is_dead() -> bool:
	return dead
	
################################################# MOVEMENT METHODS #################################################
# Method to fli character
func change_state():
	print(state_machine.get_current_node())
	if !state_machine.get_current_node() != "Walk":
		# Walk to left
		velocity.x *= -1
		# Face left
		scale.x *= -1
		# If goes to left
		if velocity.x < 0:
			turned_side = true
		# If goes to right
		elif velocity.x > 0:
			turned_side = false

# Method that sets animation depending of the velocity
func set_animation_movement():
	# IF is alive
	if health > 0:
		# If doesn't move
		if velocity.x == 0:
			# Plays the Idle animation
			state_machine.travel('Idle')
		# If its velocity is less than 100 on right or left
		elif velocity.x < 100 and velocity.x > -100:
			# Plays walk animation
			state_machine.travel('Walk')
		# if its velocity is  more than 99 on right or left
		elif velocity.x > 99 or velocity.x < -99:
			# Plays Run animation
			state_machine.travel('Run')

func stop_moving():
	# If there is a player in front or is animating the Hit
	if detech_player_towards() or state_machine.get_current_node() == "Hit":
		# STOP MOVING
		velocity = Vector2(0, 0)

# Start moving character
func start_moving():
	# If is alive
	if health > 0:
		# If character isn't in front
		if !detech_player_towards():
				# Moves with the default velocity
				speed = default_speed
				# If faces right
				if !turned_side:
					# Walks to right
					velocity.x = speed
				# Else
				else:
					# Walks to left
					velocity.x = speed * -1
		# Play to correct animation depending of the velocity
		set_animation_movement()

# if There is a player in front
func detech_player_towards() -> bool:
	# if RayCast is colliding with anything
	if raycast_detech_player_towards.is_colliding():
		# Saves the name of the body with which is colliding
		var body = raycast_detech_player_towards.get_collider()
		# If the body is actually the Player
		if body.is_in_group(group_player):
			# get a random number
			var select_attack = rand_range(0, 10)
			# If the number is lower or equal 5
			if select_attack <= 5:
				# Play attack melee animation
				state_machine.travel('Attack_melee')
			# if the number is higher than 5
			else:
				# Playe attack ground animation
				state_machine.travel('Attack_ground')
			return true
		else:
			return false
	else:
		return false
	
# Detects an object in front
func _detech_wall() -> bool:
	return raycast_detech_wall.is_colliding()

# Detechts an object under
func _detech_floor() -> bool:
	return raycast_detech_floor.is_colliding()

# Detech the player if is behind to change direction to face the player
# warning-ignore:function_conflicts_variable
func raycast_detech_player_behind() -> bool:
	# If is alive
	if health > 0:
		# If the raycast which points behind touches anything..
		if raycast_detech_player_behind.is_colliding():
			# saves the name of the object that's behind
			var body = raycast_detech_player_behind.get_collider()
			# If the body is actually the Player
			if body.is_in_group(group_player):
				# Returns true
				return true
			else:
				return false
		else:
			return false
	else:
		return false
	

# If the player gets into this area, deals damage to the player with the melee Attack
func _on_area2d_attack_melee_body_entered(body):
	if body.is_in_group(group_player):
		body.damage_ctrl(attack_melee_daamge)


# If the player gets into this area, deals damage to the player with the ground Attack
func _on_area2d_attack_ground_body_entered(body):
	if body.is_in_group(group_player):
		body.damage_ctrl(attack_ground_damage)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Dead":
			dead = true
			GAME.score += mob_score
