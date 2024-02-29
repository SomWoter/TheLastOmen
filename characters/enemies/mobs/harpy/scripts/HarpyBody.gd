class_name HarpyBody
extends KinematicBody2D


onready var state_machine = $AnimationTree.get('parameters/playback')
onready var raycast=$AccelRaycast
onready var health_bar = $HealthBar
onready var timer = $Timer
onready var detect_player = $detect_player/CollisionShape2D
onready var attack_player = $attack_player/CollisionShape2D
onready var player_back = $player_is_back/CollisionShape2D
onready var collision_enemy= $CollisionShape2D
onready var harpy = $"."

var turned_side

var velocity =Vector2(50,0)
var gravity =0
var damage= 15
var health=60
var group_player='Player'

const mob_score = 100

func _ready():
	state_machine.travel('fly')

# warning-ignore:unused_argument
func _physics_process(delta):
	velocity.y=gravity
	if raycast.is_colliding():
		var body=raycast.get_collider()
		if body.is_in_group(group_player):
			state_machine.travel('fly_faster')
			if velocity.x>0:
				velocity=Vector2(200,0)
			elif velocity.x<0:
				velocity=Vector2(-200,0)
	
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.UP)

func change_state():
	velocity.x *= -1
	scale.x *= -1
	
	if velocity.x < 0:
		turned_side = true
	elif velocity.x > 0:
		turned_side = false

func _on_detect_player_body_entered(body):
	raycast.enabled = false
	if body.is_in_group(group_player):
		state_machine.travel('attack')
		velocity=Vector2(0,0)
	
func _on_detect_player_body_exited(body):
	if health>0:
		raycast.enabled = true
		if body.is_in_group(group_player):
			state_machine.travel('fly')
		if turned_side == true:
			velocity.x=-50
		elif turned_side == false:
			velocity.x=50

func _on_Area2D_body_entered(body):
	if body.is_in_group(group_player):
		#CONECTARLO CON EL PLAYER
		body.damage_ctrl(damage)

func _on_player_is_back_body_entered(body):
	if health>0:
		if body.is_in_group(group_player):
			change_state()
		
# warning-ignore:shadowed_variable
func damage_ctrl(damage):
#	print(health)
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
		 Vector2(0,0)
# warning-ignore:standalone_expression
		 state_machine.travel('death')
		 GAME.mobs_killed += 1
		 GAME.score += mob_score
		 health_bar.visible = false
		 detect_player.disabled = true
		 attack_player.disabled = true
		 player_back.disabled = true
		 raycast.enabled=false
		 collision_enemy.disabled=true

func _on_Timer_timeout():
	health_bar.visible = false
