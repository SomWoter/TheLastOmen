class_name Medusa
extends InteractableMob
##############################  NODE REFERENCE  ################################
onready var medusa = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var attack_area = $AttackArea
onready var player_detection_melee_area = $PlayerDetectionAttackArea
onready var player_detection_attack_collision = $PlayerDetectionAttackArea/PlayerDetectionAttackCollision
onready var animation = $Animation
onready var damage_animation = $DamageAnimation
onready var animation_tree = $AnimationTree
onready var raycasts = $Raycasts
onready var floor_raycast = $Raycasts/NoFloorRaycast
onready var player_detection_raycast = $Raycasts/PlayerDetectionDialogRaycast
onready var spell_raycast = $Raycasts/SpellRange
onready var player_on_back = $Raycasts/PlayerOnBackRaycast
onready var health_bar = $HealthBar

###############################  VARIABLES  ####################################
var playback : AnimationNodeStateMachinePlayback
###############################  CONSTANTS  ####################################
const attack_damage : int = 40
const spell_damage : int = 30

onready var end_area : LevelEnd = get_tree().get_nodes_in_group("End")[0]
## Indicates if the combat can start, right after the dialogue has ended
var triggered : bool = false
var dead : bool = false
func _ready():
	mob_score = 1000
	max_health = 500
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	SPEED = 120
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
	if triggered:
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
			"attack1","attack2","spell", "idle", "death":
				motion.x = 0
		motion = move_and_slide(motion, FLOOR)

## Function that manages when the mob has to turn around. In this case, Dark Knight
# has to turn when collides with a wall, no more floor is detected by the no floor 
# raycast.
func direction_ctrl():
	if triggered:
		if is_on_wall() or not floor_raycast.is_colliding() or player_on_back.is_colliding():
			direction *= -1
			raycasts.scale.x *= -1
			player_detection_melee_area.scale.x *= -1
			attack_area.scale.x *= -1
			sprite.position.x *= -1

## Function used in order to turn around the player once in the ready function,
# in order to make it face the left side of the screen.
func flip_mob():
	sprite.flip_h = true
	direction *= -1
	raycasts.scale.x *= -1
	player_detection_melee_area.scale.x *= -1
	attack_area.scale.x *= -1
	sprite.position.x *= -1

## Function that controls the way Dark Knight attacks the player. It will have 
# three type of attack patterns. If the player is detected by the melee detection area, 
# the melee attack animation will be played and the players inside the area will take damage.
# Moreover, if a player is detected by the spell range raycast, the charge animation
# will be played, where in the end of it will be called the cast_spell() function.
func attack_ctrl():
	#If the player was detected by the spell raycast
	if melee_range_player_detected() and triggered:
		#We play the spell animation, where the cast_spell function is called along the animation.
		playback.travel("spell")

func melee_range_player_detected() -> bool:
	var spell_can_start : bool = false
	if spell_raycast.is_colliding() and triggered:
		var body = spell_raycast.get_collider()
		if body.is_in_group("Player"):
			spell_can_start = true
		else:
			spell_can_start = false
	return spell_can_start

## Function called by the attacking body in order to make DarkKnight take damage. 
# If it still alive, it will take damage and a hit animation will be played, that will change the
# sprite modulate in order to make it look like the mob has actually taken damage.
# When the mob runs out of HP, the knee animation will be played, and a DIALOG 
# will start. When that dialog ends, using the signal the death animation will be played and t
# the mob will disappear.
func damage_ctrl(damage_to_receive : int):
	if triggered:
		if health > 0:
			health -= damage_to_receive
			health_bar.value = health
			damage_animation.play("hit")
		elif health <= 0 or health_bar.value <= 0:
	#		floor_raycast.enabled = false
			player_detection_raycast.enabled = false
			spell_raycast.enabled = false
			player_on_back.enabled = false
			player_detection_attack_collision.disabled = true
			health_bar.visible = false
			playback.travel("death")
			GAME.score += mob_score
			GAME.mobs_killed += 1
			end_area.active = true

## Function used in order to trigger when the Dark Knigth initial dialogue must start.
# In this case, it will happen once the player is detected by the detection raycast, 
# and we will call the start dialog function.Then, we will deactivate the 
# player detection raycast.
func interact_ctrl():
	if player_detection_raycast.is_colliding() and playback.get_current_node() == "idle":
		start_dialog("medusa_timeline")
		player_detection_raycast.enabled = false

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

## Function that detects the player and randomly plays the attack animation decided
# by a random generated number
func _on_PlayerDetectionAttackArea_body_entered(body):
	spell_raycast.enabled = false
	var attack_type : int
	attack_type = randi() % 2
	if (playback.get_current_node() == "walk" or playback.get_current_node() == "idle") and triggered:
		match attack_type:
			0:
				playback.travel("attack1")
			1:
				playback.travel("attack2")
		player_on_back.enabled = false

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		body.damage_ctrl(attack_damage)


# warning-ignore:unused_argument
func _on_PlayerDetectionAttackArea_body_exited(body):
	if playback.get_current_node() != "death":
		spell_raycast.enabled = true
	player_on_back.enabled = true
