class_name DarkOmi
extends Mob
##############################  NODE REFERENCE  ################################
onready var dark_omi = $"."
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var animation = $Animation
onready var animation_tree = $AnimationTree
onready var attack_area = $AttackArea
onready var attack_collision = $AttackArea/AttackCollision
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
var melee_attack_damage : int = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	direction_ctrl()
	GRAVITY = 50
	SPEED = 0
	max_health = 800
	shield_max_health = 400
	health = max_health
	shield_health = shield_max_health
	playback = animation_tree.get("parameters/playback")
	playback.start("omi_idle")
	animation_tree.active = true
	
	
	#We set the health texture progress value as the value of the boss max health
	health_bar.max_value = max_health
	#We set the health texture progress value as the value of the boss shield max health
	shield_bar.max_value = shield_max_health
func _process(_delta):
	#We updated the bars value accordint to its respective value.
	health_bar.value = health
	shield_bar.value = shield_health

# Dark Omi itself will not move. We use this function in order to set the facing direction
# of the boss.
func movement_ctrl():
	motion.y += GRAVITY
	motion.x = 0
	motion = move_and_slide(motion, FLOOR)

func direction_ctrl():
	sprite.flip_h = true
	hitbox.scale.x *= -1
	attack_area.scale.x *= -1
	spell_spawns.scale.x *= -1
	raycast.scale.x *= -1
	
## Function used in order to trigger when to activate the final boss dialog
#func interact_ctrl():
#	if player_detection_raycast.is_colliding():
#		var npc_interaction = NPC.new()
#		npc_interaction.start_dialog("omicidal_timeline")
#		player_detection_raycast.enabled = false
func attack_ctrl():
	pass

## Function that manages the way Dark Omi receives damage. Depending on the value of 
# the shield and health bars, the damage will be taken to one or to other bar. 
# Once the health reaches certain points, Dark Omi will play the vanish animation and
# an horde of MiniOmis will appear. Once the vanish animation is done, vanish in 
# will be played and the mini omis spawns will be deactivated.
# Once the shield bar is empty, tlo_weak animation will be played, when the 
# player will be able to damage Omi's health. Once the health reached zero, 
# tlo_death animation will be played.
func damage_ctrl(damage_to_receive : int):
	match playback.get_current_node():
		"omi_to_tlo", "tlo_idle", "tlo_attack","tlo_spell", "tlo_stomp":
			if health > 0:
				shield_health -= damage_to_receive
			else:
				playback.travel("tlo_death")
		"tlo_weak":
			if shield_health > 0:
				health -= damage_to_receive
			else:
				playback.travel("tlo_weak")
