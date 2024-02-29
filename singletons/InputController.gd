extends Node

##############################  INPUT VARIABLES  ###############################
	# Stores the string value of the input pressed, detected in the Player.gd script.

func set_singleplayer_controls(single_player : Player):
	single_player.move_right_input = "move_right"
	single_player.move_left_input = "move_left"
	single_player.crouch_input = "crouch"
	single_player.jump_input = "jump"
	single_player.run_input = "run"
	single_player.dash_input = "dash"
	single_player.primary_attack_input = "primary_attack"
	single_player.secondary_attack_input = "secondary_attack"
	single_player.ultimate_attack_input = "ultimate"
	single_player.transform_input = "transform"
	single_player.block_input = "block"

# Method that sets the input variables value from the InputController Singleton as the value requiered
# for the player instance received by parameter.
# @param player: the player Resource instance we want to apply the control changes.
func set_j1_controls(player1):
	player1.move_right_input = "move_right_j1"
	player1.move_left_input = "move_left_j1"
	player1.crouch_input = "crouch_j1"
	player1.jump_input = "jump_j1"
	player1.run_input = "run_j1"
	player1.dash_input = "dash_j1"
	player1.primary_attack_input = "primary_attack_j1"
	player1.secondary_attack_input = "secondary_attack_j1"
	player1.ultimate_attack_input = "ultimate_j1"
	player1.transform_input = "transform_j1"
	player1.block_input = "block_j1"

# Method that sets the input variables value from the InputController Singleton as the value requiered
# for the player instance received by parameter.
# @param player: the player Resource instance we want to apply the control changes. 
func set_j2_controls(player2):
	player2.move_right_input = "move_right_j2"
	player2.move_left_input = "move_left_j2"
	player2.crouch_input = "crouch_j2"
	player2.jump_input = "jump_j2"
	player2.run_input = "run_j2"
	player2.dash_input = "dash_j2"
	player2.primary_attack_input = "primary_attack_j2"
	player2.secondary_attack_input = "secondary_attack_j2"
	player2.ultimate_attack_input = "ultimate_j2"
	player2.transform_input = "transform_j2"
	player2.block_input = "block_j2"
