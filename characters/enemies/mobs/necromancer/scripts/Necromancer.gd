class_name Necromancer
extends Mob

##############################  NODE REFERENCE  ################################
onready var necromancer = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var animation = $Animation
onready var animation_tree = $AnimationTree
onready var player_detection_melee_area = $PlayerDetectionMeleeArea
onready var player_detection_melee_collision = $PlayerDetectionMeleeArea/PlayerDetectionCollision
onready var attack_area = $AttackArea
onready var attack_collision = $AttackArea/AttackCollision
onready var spell_spawn = $SpellSpawn
onready var health_bar = $HealthBar
onready var raycasts = $Raycasts
onready var spell_raycast = $Raycasts/SpellRaycast
onready var player_on_back = $Raycasts/PlayerOnBackRaycast
onready var floor_raycast = $Raycasts/FloorRaycast
#############################  SCENE REFERENCE  ################################

###############################  VARIABLES  ####################################
var playback : AnimationNodeStateMachinePlayback
export var melee_attack_damage : int = 30

# In the ready function we set the values for the attributes for this Mob in particular.
func _ready():
	mob_score = 100
	max_health = 100
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	SPEED = 100
	GRAVITY = 50
	casted_spell = preload("res://characters/enemies/mobs/necromancer/scenes/NecroBall.tscn")
	playback = animation_tree.get("parameters/playback")
	playback.start("idle")
	animation_tree.active = true

func movement_ctrl():
	if direction == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	direction_ctrl()
	motion.y += GRAVITY
	motion.x = SPEED * direction
	playback.travel("walk")
	match playback.get_current_node():
		"spell", "death", "hit", "melee":
			motion.x = 0
	motion = move_and_slide(motion, FLOOR)

# Function used in movement_ctrl in order to manage the direction states and flip all the elements
# of the mob scene.
func direction_ctrl():
	if is_on_wall() or not floor_raycast.is_colliding():
			direction *= -1
			raycasts.scale.x *= -1
			player_detection_melee_area.scale.x *= -1
			attack_area.scale.x *= -1
			spell_spawn.position.x *= -1

func damage_ctrl(damage_to_receive : int):
	# If the mob is still alive, which means that has at least one HP...
	if health > 0:
		#We play the hit animation
		playback.travel("hit")
		health -= damage_to_receive
		health_bar.value = health
	#If the player has no more HP, means he has to die...
	else:
		health_bar.visible = false
		playback.travel("death")
		GAME.score += mob_score

# Function that controlls the way 
func attack_ctrl():
	#If the player was detected by the spell raycast
	if melee_range_player_detected():
		#We play the spell animation, where the cast_spell function is called along the animation.
		playback.travel("spell")
	
#Function that gets if the player was detected by the long range spell detection 
# raycast of the mob.
func melee_range_player_detected() -> bool:
	var spell_can_start : bool = false
	if spell_raycast.is_colliding():
		var body = spell_raycast.get_collider()
		if body.is_in_group("Player"):
			spell_can_start = true
		else:
			spell_can_start = false
	return spell_can_start

# Function called along the spell animation in order to spawn the mob spell.
# The spell direction and speed will be correted depending on the direction the mob is facing.
func cast_spell():
	var spell = casted_spell.instance()
	spell.damage = 50
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	match sprite.flip_h:
		true:
			spell.scale.x *= -1
			spell.direction = -spell.MOVEMENT_SPEED
		false:
			spell.scale.x *= 1
			spell.direction = spell.MOVEMENT_SPEED

func _on_AttackArea_body_entered(body : Player):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		body.damage_ctrl(melee_attack_damage)

#Function of the Area that is permanently enabled in order to detect the player.
# This will trigger the melee animation to start.
func _on_PlayerDetectionMeleeArea_body_entered(body):
	if body.is_in_group("Player"):
		playback.travel("melee")

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"death":
			queue_free()
