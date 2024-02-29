class_name Omicidal
extends InteractableMob
##############################  NODE REFERENCE  ################################
onready var dark_omi = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var animation = $Animation
onready var damage_animator = $DamageAnimator
onready var animation_tree = $AnimationTree
onready var attack_area = $AttackArea
onready var attack_collision = $AttackArea/AttackCollision
onready var damage_area = $DamageArea
onready var damage_collision = $DamageArea/DamageCollision
onready var spell_spawns = $SpellSpawns
onready var ice_spawn = $SpellSpawns/IceParanoiaSpawn
onready var light_spawn = $SpellSpawns/LightParanoiaSpawn
onready var fire_spawn = $SpellSpawns/FireParanoiaSpawn
onready var necro_spawn = $SpellSpawns/NecroParanoiaSpawn
onready var death_spawn = $SpellSpawns/DeathParanoiaSpawn
onready var soul_spawn = $SpellSpawns/SoulParanoiaSpawn
onready var stomp_spawn = $SpellSpawns/StompParanoiaSpawn
onready var boss_gui = $BossGUI
onready var health_bar = $BossGUI/BossGUIContainer/HealthBar
onready var shield_bar = $BossGUI/BossGUIContainer/ShieldBar
onready var raycast = $Raycasts
onready var player_detection_raycast = $Raycasts/PlayerDetectionDialogRaycast
onready var shield_cooldown_timer = $ShieldCooldownTimer
onready var damage_timer = $DamageTimer
#############################  SCENE REFERENCE  ################################
var ice_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/IceParanoia.tscn")
var light_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/LightParanoia.tscn")
var fire_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/FireParanoia.tscn")
var necro_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/NecroParanoia.tscn")
var death_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/DeathParanoia.tscn")
var soul_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/SoulParanoia.tscn")
var stomp_paranoia = preload("res://characters/enemies/final_boss/giga-omi/scenes/StompParanoia.tscn")
###############################  VARIABLES  ####################################
var playback : AnimationNodeStateMachinePlayback

var attack_damage : int = 50
var paranoia_damage : int = 30
var stomp_damage : int

var second_fase : bool = false

onready var miniomis_spawns : Array = get_tree().get_nodes_in_group("MobSpawn")
onready var end_area : LevelEnd = get_tree().get_nodes_in_group("End")[0]

# Called when the node enters the scene tree for the first time.
# Called when the node enters the scene tree for the first time.
func _ready():
	boss_gui.visible = false
	mob_score = 10000
	GRAVITY = 50
	SPEED = 0
	max_health = 2000
	shield_max_health = 750
	health = max_health
	shield_health = shield_max_health
	playback = animation_tree.get("parameters/playback")
	playback.start("omi_idle")
	animation_tree.active = true
	#We set the health texture progress value as the value of the boss max health
	health_bar.max_value = max_health
	#We set the health texture progress value as the value of the boss shield max health
	shield_bar.max_value = shield_max_health
	end_area.active = false
	#We flip the boss using direction_ctrl
	direction_ctrl()

func _process(_delta):
	#We updated the bars value accordint to its respective value.
	health_bar.value = health
	shield_bar.value = shield_health
	if playback.get_current_node() == "idle":
		attack_triggered = true

# Dark Omi itself will not move. We use this function in order to set the facing direction
# of the boss.
func movement_ctrl():
	motion.x = 0
	match playback.get_current_node():
		#Normal gravity circumstancies
		"idle", "to_omicidal", "omi_idle", "attack", "spell", "weak", "stomp","death", "to_weak":
			motion.y += GRAVITY
		#No gravity circumstancies, and we deactivate the hitbox collision of the boss
		"vanish_in", "vanish_out":
			motion.y = 0
	motion = move_and_slide(motion, FLOOR)

func direction_ctrl():
	sprite.flip_h = true
	hitbox.scale.x *= -1
	attack_area.scale.x *= -1
	spell_spawns.scale.x *= -1
	raycast.scale.x *= -1
	
## Function used in order to trigger different type of attacks depending on the reamaining
# health the mob has. If the mob has more than half of its HP remaining, he will
# randomly pick an attack by generating a random number from zero to two, the attacks
# he will have available. Once its health has reached less than the half, it will
# unlock the fourth and last attack and the generated number will be chosen between 
# 0 to 3.
func attack_ctrl():
	match playback.get_current_node():
		"idle", "to_omicidal":
			var attack_type : int
			attack_type = randi() % 7 #Gets an integer in the interval 0-7
#			attack_type = randi() % 8 #Gets an integer in the interval 0-7
#			if second_fase:
#				attack_type = randi() % 4 #Gets an integer in the interval 0-3
#			else:
#				attack_type = randi() % 3 #Gets an integer in the interval 0-2
			match attack_type:
				0, 1:
					playback.travel("spell")
				2, 3:
					playback.travel("stomp")
				4, 5, 6:
					playback.travel("attack")

##Function called along the spell animation in order to cast the six different types
# of paranoia Omicidal has.
func cast_spells():
	var spell_list = []
	var ice_paranoia_spell : Spell = ice_paranoia.instance()
	spell_list.append(ice_paranoia_spell)
	ice_paranoia_spell.global_position = ice_spawn.global_position
	ice_paranoia_spell.rotation_degrees = -ice_spawn.rotation_degrees
	ice_paranoia_spell.vert_direction = ice_spawn.rotation_degrees
#	ice_paranoia_spell.damage = paranoia_damage
	var light_paranoia_spell : Spell = light_paranoia.instance()
	light_paranoia_spell.global_position = light_spawn.global_position
	light_paranoia_spell.rotation_degrees = -light_spawn.rotation_degrees
	light_paranoia_spell.vert_direction = light_spawn.rotation_degrees
	spell_list.append(light_paranoia_spell)
#	light_paranoia_spell.damage = paranoia_damage
	var fire_paranoia_spell : Spell = fire_paranoia.instance()
	fire_paranoia_spell.global_position = fire_spawn.global_position
	fire_paranoia_spell.rotation_degrees = -fire_spawn.rotation_degrees
	fire_paranoia_spell.position.y += -fire_spawn.rotation_degrees
	fire_paranoia_spell.vert_direction = fire_spawn.rotation_degrees
	spell_list.append(fire_paranoia_spell)
	
#	fire_paranoia_spell.damage = paranoia_damage
	var necro_paranoia_spell : Spell = necro_paranoia.instance()
	necro_paranoia_spell.global_position = necro_spawn.global_position
	necro_paranoia_spell.rotation_degrees = -necro_spawn.rotation_degrees
	necro_paranoia_spell.vert_direction = necro_spawn.rotation_degrees
	spell_list.append(necro_paranoia_spell)
#	necro_paranoia_spell.damage = paranoia_damage
	var death_paranoia_spell : Spell = death_paranoia.instance()
	death_paranoia_spell.global_position = death_spawn.global_position
	death_paranoia_spell.rotation_degrees = -death_spawn.rotation_degrees
	death_paranoia_spell.vert_direction = death_spawn.rotation_degrees
	spell_list.append(death_paranoia_spell)
#	death_paranoia_spell.damage = paranoia_damage
	var soul_paranoia_spell : Spell = soul_paranoia.instance()
	soul_paranoia_spell.global_position = soul_spawn.global_position
	soul_paranoia_spell.rotation_degrees = -soul_spawn.rotation_degrees
	soul_paranoia_spell.vert_direction = soul_spawn.rotation_degrees
	spell_list.append(soul_paranoia_spell)
#	soul_paranoia_spell.damage = paranoia_damage
	for spell in spell_list:
		spawn_spell(spell)
func spawn_spell(spell : Spell):
	spell.damage = paranoia_damage
	spell.scale.x = 6
	spell.scale.y = 6
	spell.MOVEMENT_SPEED = 100
	spell.scale.x *= -1
	spell.direction = -spell.MOVEMENT_SPEED
	get_parent().add_child(spell)

func stomp_attack():
# warning-ignore:unused_variable
	var stomp_paranoia_spell = stomp_paranoia.instance()
	stomp_paranoia_spell.damage = stomp_damage
	stomp_paranoia_spell.global_position = stomp_spawn.global_position
	get_parent().add_child(stomp_paranoia_spell)

func vanish_attack():
	for spawn  in miniomis_spawns:
		spawn.active = true

func close_spawns():
	for spawn in miniomis_spawns:
		spawn.active = false

## Function that makes Omicidal take damage. Depending on the animation is playing, 
# the damage to receive will be taken from the general health or from the shield health.
# If the shield health reaches 0, the to_weak animation will be played and from there
# the boss will be weak to any type of attacks and the ShieldCooldownTimer will start filling up
# the shield bar again. Once is completely full, the boss will turn again into Omicidal.
# Moreover, each time that one fourth of the general health has been taken, the 
# vanish out animation is played and the Mini Omis Spawns existant in the level are
# activated. Once that animation has finished, vanish in is played and the spawns are deactivated.
# Once the general health has reached 0, Omicidal dies and the dark energy particles are
# emmited up to the air.
func damage_ctrl(damage_to_receive : int):
	match playback.get_current_node():
		"attack", "spell", "stomp", "idle":
			# If the shield has health enough in order to get the impact and is bigger than 0
			if shield_health > 0:
				#We take the damage from the shield health
				shield_health -= damage_to_receive
				damage_animator.play("hit")
			elif shield_health <= 0:
				#We play the to weak animation, where the damage will be taken from the general health
				playback.travel("to_weak")
#				print("Damage dealt to Omicidal")
				shield_cooldown_timer.start()
			
		"weak":
			if health > 0 and shield_health < shield_max_health:
				health -= damage_to_receive
				damage_animator.play("weak_hit")
#				print("Damage dealt to weak Omi")
			else:
				playback.travel("death")
				end_area.active = true
				GAME.score += mob_score
				GAME.mobs_killed += 1
			if shield_health >= shield_max_health and health > 0:
				shield_cooldown_timer.stop()
				playback.travel("to_omicidal")
#			else:
#				playback.travel("death")

func interact_ctrl():
	if player_detection_raycast.is_colliding() and playback.get_current_node() == "omi_idle":
		start_dialog("omicidal_timeline")
		player_detection_raycast.enabled = false
#		boss_gui.visible = true

## Function that connects the emmited signals from the character timeline.
func connect_needed_signals():
	character_dialog.connect("dialogic_signal", self, "dialogic_signal_event")
	character_dialog.connect("timeline_end", self, "close_dialog")
	
func dialogic_signal_event(event_to_do : String):
	match event_to_do:
		"absorb_and_transform":
			playback.travel("to_omicidal")
			boss_gui.visible = true

func start_death_dialog():
	start_dialog("omicidal_end")

## Signal used in order to fill up the shield bar again
func _on_ShieldCooldownTimer_timeout():
	if shield_health < shield_max_health and playback.get_current_node() == "weak":
		shield_health += 1
	elif shield_health >= shield_max_health and playback.get_current_node() == "weak":
		playback.travel("to_omicidal")

## Function that makes damage to all the player bodies that get in here.
# warning-ignore:unused_argument
func _on_DamageArea_body_entered(body):
	pass # Replace with function body.


func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"to_omicidal":
			attack_triggered = true
#			boss_gui.visible = true
		"death":
			end_area.active = true

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_ctrl"):
		body.damage_ctrl(attack_damage)
