class_name Skeleton_warrior
extends KinematicBody2D

onready var state_machine = $AnimationTree.get('parameters/playback')
onready var raycast_detech_floor = $Raycast_detech_floor
onready var raycast_detech_wall = $Raycast_detech_wall
onready var raycast_detech_player_towards = $Raycast_detech_player_towards
onready var health_bar = $Health_bar

export var SPEED = 100
export var health = 300
export var attack_melee_daamge = 10
#export var attack_ground_damage = 30
export var inmune_damage = 20

const mob_score = 100

var speed = SPEED
var default_speed = SPEED
var velocity = Vector2(speed, 0)
var UP = Vector2(0, -1)
var gravity = 1

var turned_side = false
var group_player = "Player"

var block = false
var lifes = 3

func _ready():
	set_animation_movement()
	health_bar.value = health
	health_bar.max_value = health

# warning-ignore:unused_argument
func _physics_process(delta):
	velocity.y += gravity
	# If is alive	
	if health > 0:
		if !_detech_floor() or _detech_wall() and is_on_floor() and !detech_player_towards() and raycast_detech_player_towards.enabled:
			change_state()			# IF there is a player in front
		if detech_player_towards():
			pass
	else:
		# If is not alive, dies
		prints(lifes)
		if lifes > 0:
			lifes -= 1
			health_bar.value = 300
			health_bar.max_value = 300
			health = 300
			state_machine.travel("Fake_Dead")
#			GAME.score += mob_score / 2
			return
		else:
			state_machine.travel("Dead")
#			GAME.score += mob_score
#			GAME.mobs_killed += 1
			return
	# Apllies the velocity and gravity
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

# if There is a player in front
func detech_player_towards() -> bool:
	# if RayCast is colliding with anything
	if raycast_detech_player_towards.is_colliding():
		# Saves the name of the body with which is colliding
		var body = raycast_detech_player_towards.get_collider()
		# If the body is actually the Player
		if body.is_in_group(group_player):
			execute_attack_melee()
			return true
		else:
			return false
	else:
		return false
# Method for receiving damgage from other body
func damage_ctrl(damage):
	# If is alive
	if health > 0 and !block:
			# Play animation of hit
			#state_machine.travel('Hit')
			# Receive the damage to the health
			health -= damage
			# Refresh health bar value
			health_bar.value = health
	elif health > 0:
		#state_machine.travel('Blocked')
		pass
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
# Method to fli character
func change_state():
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

func stop_moving():
	# If there is a player in front or is animating the Hit
	if detech_player_towards() or state_machine.get_current_node() == "Hit" or state_machine.get_current_node() == "Fake_Dead":
		# STOP MOVING
		velocity = Vector2(0, 0)

func start_moving():
	print(state_machine.get_current_node())
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
		else:
			stop_moving()
		# Play to correct animation depending of the velocity
		set_animation_movement()
# Detects an object in front
func _detech_wall() -> bool:
	return raycast_detech_wall.is_colliding()
# Detechts an object under
func _detech_floor() -> bool:
	return raycast_detech_floor.is_colliding()
func set_block_true():
	block = true
func set_block_false():
	block = false
func _on_Area2d_attack_body_entered(body):
	if body.is_in_group(group_player):
		body.damage_ctrl(attack_melee_daamge)
func execute_attack_melee():
	state_machine.travel('Attack')


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Fake_Dead":
			GAME.score += mob_score / 2
		"Dead":
			GAME.score += mob_score
			GAME.mobs_killed += 1
