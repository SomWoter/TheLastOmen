class_name YouDiedPanel
extends Control
################################### CLASS NAME #################################

################################# NODE REFERENCES ##############################
onready var you_died_screen = $"."
onready var you_died_panel = $YouDiedPanel

onready var retry_button = $YouDiedPanel/VBoxContainer/RetryButton
onready var menu_button = $YouDiedPanel/VBoxContainer/MenuButton
onready var quit_button = $YouDiedPanel/VBoxContainer/QuitButton

onready var animation = $AnimationPlayer
################################ SCENE REFERENCES ##############################
onready var main_menu_scene = "res://gui/screens/main_menu/scenes/MainMenu.tscn"
const EXIT_DIALOG_SCENE = preload("res://gui/screens/exit_dialog/scenes/ExitDialog.tscn")
################################## VARIABLES ###################################

func _ready():
	#We hide the panel until the opening animation is finished
	you_died_panel.visible = false
	animation.play("background_fade_in")
	focus()
	
#func _process(_delta):
#	if visible:
#		focus()

func focus():
	retry_button.grab_focus()

func _on_RetryButton_pressed():
	get_tree().paused = false
#	get_parent().get_tree().change_scene(GAME.current_level)
	visible = false
# warning-ignore:return_value_discarded
#	get_tree().change_scene(GAME.current_level)
	get_tree().reload_current_scene()
#	GAME.load_game()
# warning-ignore:standalone_expression
#	GAME.level_start

func _on_MenuButton_pressed():
# warning-ignore:return_value_discarded
	#Parent is GUI, parent of GUI is level.
#	get_parent().get_tree().change_scene(main_menu_scene)
	visible = false
	get_tree().change_scene(main_menu_scene)
#	get_tree().change_scene(main_menu_scene)

func _on_QuitButton_pressed():
	var exit_dialog_scene = EXIT_DIALOG_SCENE.instance()
	get_parent().add_child(exit_dialog_scene)
# warning-ignore:return_value_discarded
	EXIT_DIALOG_SCENE.connect("popup_exited", self, "on_dialog_closed")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"background_fade_in":
			you_died_panel.visible = true
			animation.play("panel_animation")
