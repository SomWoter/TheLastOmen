class_name Ghost
extends KinematicBody2D

##########################  NODE REFERENCES ####################################
onready var state_machine = $AnimationTree.get('parameters/playback')
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var detech_wall = $detech_wall
#onready var detech_floor = $detech_floor
onready var detech_player_away = $detech_player_away
onready var detech_back = $detech_back
onready var position2D = $Position2D
onready var health_bar = $HealthBar
onready var timer = $Timer
onready var sprite = $Sprite
############################  SCENE REFERENCES #################################
const BALL = preload("res://characters/enemies/mobs/ghost/scenes/SoulBall.tscn")
###############################  CONSTANTS  #################################### 

###############################  STATS VARIABLES  ##############################
var SPEED = 120
var health = 150

var speed = SPEED
var default_speed = SPEED
var velocity = Vector2(speed, 0)
var UP = Vector2(0,-1)
var gravity = 0
var damage_spell = 15
###############################  BOOLEAN VARIABLES  ############################
var turned_side = false

##################################  CONSTANTS ##################################
const mob_score = 100
##################################  FUNCTIONS  #################################
func _ready():
	#################################################################################
	# When the ejecution starts, the "walk" animation begins
	set_animation_movement()
	health_bar.value = health
	health_bar.max_value = health

# warning-ignore:unused_argument
func _physics_process(delta):
	#We apply gravity
	velocity.y += gravity
	if health > 0:
		set_animation_movement()
		
		if _detech_wall()  or detech_back() and is_on_floor():
			change_state()
		
		if detech_player_away.is_colliding():
			var o = detech_player_away.get_collider()
			if o.is_in_group("Player"):
				shoot_ball()
	else:
		state_machine.travel("Dead")
#		GAME.score += mob_score
		return
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

func set_animation_movement():
	if health > 0:
		if speed == 0:
			state_machine.travel('Idle')
		elif speed < 100 and speed > -100:
			state_machine.travel('Walk')
		elif speed > 99 or speed < -99:
			state_machine.travel('Run')

func stop_moving():
	speed = 0
	velocity = Vector2(speed, 0)
	
func start_moving():
	if health > 0:
		if !turned_side:
			speed = default_speed
			velocity = Vector2(speed, 0)
		else:
			speed = default_speed * -1
#			print(speed)
			velocity = Vector2(speed, 0)
		set_animation_movement()
		
############################################ CHANGE DIRECTION ###################################################
# Method to change the direction 
func change_state ():
		var correct_direction = -1
		position2D.position.x *= correct_direction
		velocity.x *= correct_direction
		scale.x *= correct_direction
		if velocity.x < 0:
			turned_side = true
		elif velocity.x > 0:
			turned_side = false
############################################# DETECH FLOOR AND WALL #############################################
func _detech_wall() -> bool:
	return detech_wall.is_colliding()
#func _detech_floor() -> bool:
#	return detech_floor.is_colliding()
############################################# SHOOT ARROW #######################################################

func shoot_ball():
	state_machine.travel('Attack')
	# Set the timer to 1 second
	timer.wait_time = 1
	# Execute the timer and starts counting 1 second
	timer.start()

func spawn_spell():
	var ball = BALL.instance()
	ball.damage = damage_spell
	ball.scale.x = 2
	ball.scale.y = 2
	
	get_parent().add_child(ball)
	
	ball.position = position2D.global_position 
	match sprite.flip_h:
		true:
			ball.scale.x *= -1
			ball.direction = -ball.MOVEMENT_SPEED
		false:
			ball.scale.x*= 1
			ball.direction = ball.MOVEMENT_SPEED

############################################# DETECH PLAYER #####################################################
# warning-ignore:function_conflicts_variable
func detech_player_away():
	return detech_player_away.is_colliding()
# warning-ignore:function_conflicts_variable
func detech_back():
	return detech_back.is_colliding()
############################################# RECIEVE DAMAGE ####################################################
func damage_ctrl(damage):
	
	# If he get hit, its health bar shows up
	health_bar.visible = true
	# Its health gets lower depending of the damage recieved
	health -= damage
	#state_machine.travel('hit')
	# The health bar shows the actual health remaining
	health_bar.value = health
	# Set the timer to 1 second
	timer.wait_time = 1
	# Execute the timer and starts counting 1 second
	timer.start()
	# If the bull has 0 or less health, the animation dead is executed and its health bar hides
	if health <= 0 :
		 stop_moving()
		 state_machine.travel('Dead')
		 health_bar.visible = false

# After 1 second counting on timer, the health bar dissapear if the bull didn't get hurt after 1 second
func _on_Timer_timeout():
	health_bar.visible = false

func delete_this():
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func _on_detech_back_body_entered(body):
	if body.is_in_group("Player"):
		change_state()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Dead":
			GAME.score += mob_score
			GAME.mobs_killed += 1
