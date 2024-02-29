class_name MiniOmi
extends Mob

##############################  NODE REFERENCE  ################################
onready var necromancer = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var animation = $Animation
onready var animation_tree = $AnimationTree
onready var attack_area = $AttackArea
onready var attack_collision = $AttackArea/AttackCollision
onready var player_detection_area = $PlayerDetectionArea
onready var player_detection_collision = $PlayerDetectionArea/PlayerDetectionCollision
onready var raycasts = $Raycasts
onready var player_on_back = $Raycasts/PlayerOnBackRaycast
onready var floor_raycast = $Raycasts/FloorRaycast
#############################  SCENE REFERENCE  ################################

###############################  VARIABLES  ####################################
var attack_damage : int = 20
var playback : AnimationNodeStateMachinePlayback

func _ready():
	max_health = 100
	health = max_health
	SPEED = 150
	GRAVITY = 50
	playback = animation_tree.get("parameters/playback")
	playback.start("tlo_vanish_in")
	animation_tree.active = true

# Function that controlls the movemement of the MiniOmi. It will start moving once
# the animation of vanish-in has finished.
func movement_ctrl():
	if direction == 1:
		sprite.flip_h = false
	elif direction == -1:
		sprite.flip_h = true
	#We have complete control of the change of the facing direction using direction control
	direction_ctrl()
	#We apply the gravity to the mob
	motion.y += GRAVITY
	playback.travel("tlo_run")
	motion.x = SPEED * direction
	match playback.get_current_node():
		"tlo_vanish_in", "tlo_attack", "tlo_vanish_out":
			motion.x = 0
	motion = move_and_slide(motion, FLOOR)
## Function that makes MiniOmi turn around and stare to the opposite direction if
# it collides with a wall or if the player on back raycast detect the player.
func direction_ctrl():
	if is_on_wall() or not floor_raycast.is_colliding() or player_on_back.is_colliding():
		direction *= -1
		raycasts.scale.x *= -1
		attack_area.scale.x *= -1
		player_detection_area.scale.x *= -1

func _on_PlayerDetectionArea_body_entered(body):
	if body.is_in_group("Player"):
		playback.travel("tlo_attack")
		print("MINI OMI TE HA VISTO")

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		print("SE SUPONE QUE TE ESTAN ATACANDO")
		body.damage_ctrl(attack_damage)

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"tlo_attack":
			print("MAMAGUEBO")
			playback.travel("tlo_vanish_out")
