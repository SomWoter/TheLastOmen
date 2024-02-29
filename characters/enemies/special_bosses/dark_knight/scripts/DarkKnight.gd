class_name DarkKnight
extends InteractableMob
##############################  NODE REFERENCE  ################################
onready var dark_knight = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var attack_area = $AttackArea
onready var player_detection_melee_area = $PlayerDetectionMeleeArea
onready var player_detection_melee_collision = $PlayerDetectionMeleeArea/PlayerDetectionMeleeCollision
onready var animation = $Animation
onready var damage_animation = $DamageAnimation
onready var animation_tree = $AnimationTree
onready var raycasts = $Raycasts
onready var floor_raycast = $Raycasts/NoFloorRaycast
onready var player_detection_raycast = $Raycasts/PlayerDetectionDialogRaycast
onready var spell_raycast = $Raycasts/SpellRange
onready var player_on_back = $Raycasts/PlayerOnBackRaycast
onready var health_bar = $HealthBar
onready var spell_spawns = $SpellSpawns
onready var spell_spawn1 = $SpellSpawns/SpellSpawn
onready var spell_spawn2 = $SpellSpawns/SpellSpawn2
onready var spell_spawn3 = $SpellSpawns/SpellSpawn3

###############################  VARIABLES  ####################################
var playback : AnimationNodeStateMachinePlayback
const attack_damage : int = 50
const spell_damage : int = 30

onready var end_area : LevelEnd = get_tree().get_nodes_in_group("End")[0]
## Indicates if the combat can start, right after the dialogue has ended
var triggered : bool = false
var dead : bool = false

## Function called once the node enters the tree for the first time. 
# Used in order to set the value of the Mob attributes, initizalize and start 
# the animation tree playback and set the value of the health bar.
func _ready():
	mob_score = 1000
	casted_spell = preload("res://characters/enemies/special_bosses/dark_knight/scenes/DeathBall.tscn")
	## We set the Dark Knight Boss Value
	max_health = 500
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	SPEED = 100
	GRAVITY = 50
	playback = animation_tree.get("parameters/playback")
	playback.start("idle")
	animation_tree.active = true
	## We hide the health bar until the battle has started
	health_bar.visible = false
	## We flip the mob in order to make it face to the left side of the screen
	flip_mob()
	end_area.active = false

## Movement function of the Dark Knight. It will remain in idle until sees the player
# then play the dialog and once its over, the fight starts. 
# It will advance towards the direction is facing, except if the player on back raycast 
# detects a player, when the mob will turn around.
func movement_ctrl():
	if direction == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	direction_ctrl()
	motion.y += GRAVITY
	if triggered and health > 0:
		motion.x = SPEED * direction
		playback.travel("walk")
	match playback.get_current_node():
		"attack","death","knee","spell", "idle":
			motion.x = 0
	motion = move_and_slide(motion, FLOOR)

## Function that manages when the mob has to turn around. In this case, Dark Knight
# has to turn when collides with a wall, no more floor is detected by the no floor 
# raycast.
func direction_ctrl():
	if is_on_wall() or not floor_raycast.is_colliding() or player_on_back.is_colliding():
		direction *= -1
		raycasts.scale.x *= -1
		player_detection_melee_area.scale.x *= -1
		attack_area.scale.x *= -1
		spell_spawns.scale.x *= -1

## Function used in order to turn around the player once in the ready function,
# in order to make it face the left side of the screen.
func flip_mob():
	sprite.flip_h = true
	direction *= -1
	raycasts.scale.x *= -1
	player_detection_melee_area.scale.x *= -1
	attack_area.scale.x *= -1
	spell_spawns.scale.x *= -1

## Function that controls the way Dark Knight attacks the player. It will have 
# three type of attack patterns. If the player is detected by the melee detection area, 
# the melee attack animation will be played and the players inside the area will take damage.
# Moreover, if a player is detected by the spell range raycast, the charge animation
# will be played, where in the end of it will be called the cast_spell() function.
func attack_ctrl():
	#If the player was detected by the spell raycast
	if melee_range_player_detected():
		#We play the spell animation, where the cast_spell function is called along the animation.
		playback.travel("spell")

func melee_range_player_detected() -> bool:
	var spell_can_start : bool = false
	if spell_raycast.is_colliding():
		var body = spell_raycast.get_collider()
		if body.is_in_group("Player"):
			spell_can_start = true
		else:
			spell_can_start = false
	return spell_can_start

## Function called at the end of charge animation. It will decide randomly through a random number
#  if playing the spell animation or play the heal animation, when the DarkKnight will recover
#  a fourth part of its max HP. 
func cast_spell():
	var spell1 = casted_spell.instance()
	var spell2 = casted_spell.instance()
	var spell3 = casted_spell.instance()
	spell1.damage = spell_damage
	spell2.damage = spell_damage
	spell3.damage = spell_damage
	spell1.scale.x = 3
	spell1.scale.y = 3
	spell2.scale.x = 3
	spell2.scale.y = 3
	spell3.scale.x = 3
	spell3.scale.y = 3
	
	get_parent().add_child(spell1)
	get_parent().add_child(spell2)
	get_parent().add_child(spell3)
	spell1.global_position = spell_spawn1.global_position
	spell2.global_position = spell_spawn2.global_position
	spell3.global_position = spell_spawn3.global_position
	match sprite.flip_h:
		true:
			spell1.scale.x *= -1
			spell2.scale.x *= -1
			spell3.scale.x *= -1
			spell1.direction = -spell1.MOVEMENT_SPEED
			spell2.direction = -spell2.MOVEMENT_SPEED
			spell3.direction = -spell3.MOVEMENT_SPEED
		false:
			spell1.scale.x *= 1
			spell2.scale.x *= 1
			spell3.scale.x *= 1
			spell1.direction = spell1.MOVEMENT_SPEED
			spell2.direction = spell2.MOVEMENT_SPEED
			spell3.direction = spell3.MOVEMENT_SPEED

## Function called by the attacking body in order to make DarkKnight take damage. 
# If it still alive, it will take damage and a hit animation will be played, that will change the
# sprite modulate in order to make it look like the mob has actually taken damage.
# When the mob runs out of HP, the knee animation will be played, and a DIALOG 
# will start. When that dialog ends, using the signal the death animation will be played and t
# the mob will disappear.
func damage_ctrl(damage_to_receive : int):
	if health > 0:
		health -= damage_to_receive
		health_bar.value = health
		damage_animation.play("hit")
	elif health <= 0 or health_bar.value <= 0:
#		floor_raycast.enabled = false
		player_detection_raycast.enabled = false
		spell_raycast.enabled = false
		player_on_back.enabled = false
		player_detection_melee_collision.disabled = true
		health_bar.visible = false
		playback.travel("knee")
		end_area.active = true

## Function used in order to trigger when the Dark Knigth initial dialogue must start.
# In this case, it will happen once the player is detected by the detection raycast, 
# and we will call the start dialog function.Then, we will deactivate the 
# player detection raycast.
func interact_ctrl():
	if player_detection_raycast.is_colliding() and playback.get_current_node() == "idle":
		start_dialog("dark_knight_intro_timeline")
		player_detection_raycast.enabled = false
#	if dead:
#		start_dialog("dark_knight_death_timeline")

## Function that sets the values needed for the course of the dialog timeline.
func set_needed_definition_values():
	# We set the value definitions requiered for the timeline
	Dialogic.set_variable("spell_unlocked", int(GAME.spell_unlocked))
	Dialogic.set_variable("dash_unlocked", int(GAME.dash_unlocked))
	Dialogic.set_variable("transform_unlocked", int(GAME.transform_unlocked))
	Dialogic.set_variable("ultimate_unlocked", int(GAME.ultimate_unlocked))
	Dialogic.set_variable("selected_character", GAME.selected_character)
	Dialogic.set_variable("coins", GAME.coins)
## In this function we declare value definitions needed along the played timeline.
func connect_needed_signals():
	character_dialog.connect("dialogic_signal", self, "dialogic_signal_event")
	character_dialog.connect("timeline_end", self, "close_dialog")
## By using this function, we set the action to do once the signal event_to_do is emmitted.
# @param: event_to_do, name of the signal emitted.
# warning-ignore:unused_argument
func dialogic_signal_event(event_to_do : String):
	match event_to_do:
		"start_combat":
			triggered = true
			attack_triggered = true
			health_bar.visible = true
		"die":
			playback.travel("death")
			GAME.score += mob_score
			GAME.mobs_killed += 1

func _on_PlayerDetectionMeleeArea_body_entered(body):
	spell_raycast.enabled = false
	match playback.get_current_node():
		"walk", "spell":
			playback.travel("attack")
			player_on_back.enabled = false

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		body.damage_ctrl(attack_damage)


func _on_PlayerDetectionMeleeArea_body_exited(body):
	if playback.get_current_node() != "weak":
		spell_raycast.enabled = true
	player_on_back.enabled = true

func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"knee":
			dead = true
#			print("EL BOSS SE ARRODILLO")
		"death":
			end_area.active = true
			
func start_death_dialog():
	start_dialog("dark_knight_death_timeline")
