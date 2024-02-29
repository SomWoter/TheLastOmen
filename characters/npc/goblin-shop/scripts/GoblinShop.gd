class_name GoblinShop
extends NPC

################################### NODE REFERENCE #############################
onready var animation = $AnimationPlayer
# Called when the node enters the scene tree for the first time.

##################################  ABILITY PRICES  ############################
var spell_price : int = 15
var dash_price : int = 30
var transform_price : int = 40
var ultimate_price : int = 50
var reincarnation_price : int = 100
#In the ready function of the children we set the new value definitions that we might need 
# and connect the signals emmited from that timeline.
func _ready():
	animation.play("idle")

func interact_ctrl():
	if active and !dialog_active:
		if Input.is_action_just_pressed("interact"):
			start_dialog("goblin_timeline")

## Function that sets the values needed for the course of the dialog timeline.
func set_needed_definition_values():
	# We set the value definitions requiered for the timeline
	Dialogic.set_variable("spell_unlocked", int(GAME.spell_unlocked))
	Dialogic.set_variable("dash_unlocked", int(GAME.dash_unlocked))
	Dialogic.set_variable("transform_unlocked", int(GAME.transform_unlocked))
	Dialogic.set_variable("ultimate_unlocked", int(GAME.ultimate_unlocked))
	Dialogic.set_variable("selected_character", GAME.selected_character)
	Dialogic.set_variable("coins", GAME.coins)
	
	Dialogic.set_variable("spell_price", spell_price)
	Dialogic.set_variable("dash_price", dash_price)
	Dialogic.set_variable("transform_price", transform_price)
	Dialogic.set_variable("ultimate_price", ultimate_price)
	Dialogic.set_variable("reincarnation_price", reincarnation_price)

## Function that connects the emmited signals from the character timeline.
func connect_needed_signals():
	character_dialog.connect("dialogic_signal", self, "dialogic_signal_event")
	character_dialog.connect("timeline_end", self, "close_dialog")

func dialogic_signal_event(event_to_do : String):
	match event_to_do:
		"unlock_spell":
			unlock_spell()
		"unlock_dash":
			unlock_dash()
		"unlock_transform":
			unlock_transform()
		"unlock_ultimate":
			unlock_ultimate()
		"change_to_fireman":
			change_to_fireman()
		"change_to_spearwoman":
			change_to_spearwoman()
		"change_to_viking":
			change_to_viking()

#Functions that unlocks the player spell ability for the player
func unlock_spell():
	GAME.coins -= spell_price
	GAME.spell_unlocked = true
#	GAME.save_game()

#Functions that unlocks the player spell ability for the player
func unlock_dash():
	GAME.coins -= dash_price
	GAME.dash_unlocked = true
#	print("Dash unlocked: " + str(GAME.dash_unlocked))
#	GAME.save_game()
	
#Functions that unlocks the player spell ability for the player
func unlock_transform():
	GAME.coins -= transform_price
	GAME.transform_unlocked = true
#	GAME.save_game()

#Functions that unlocks the player spell ability for the player
func unlock_ultimate():
	GAME.coins -= ultimate_price
	GAME.ultimate_unlocked = true
#	GAME.save_game()

func change_to_fireman():
	GAME.coins -= reincarnation_price
	GAME.selected_character = GAME.characters.get("Fireman")

func change_to_spearwoman():
	GAME.coins -= reincarnation_price
	GAME.selected_character = GAME.characters.get("SpearWoman")
	
func change_to_viking():
	GAME.coins -= reincarnation_price
	GAME.selected_character = GAME.characters.get("Viking")

func _on_InteractionArea_body_entered(_body):
	active = true
	
func _on_InteractionArea_body_exited(_body):
	active = false
