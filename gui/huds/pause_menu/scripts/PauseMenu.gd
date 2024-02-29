extends Control
onready var main_menu = "res://gui/screens/main_menu/scenes/MainMenu.tscn"

var is_paused = false setget set_is_paused
##############################  NODE REFERENCE #################################
onready var pause_menu = $"."
onready var resume = $CenterContainer/VBoxContainer/Resume
onready var restart = $CenterContainer/VBoxContainer/Restart
onready var quit = $CenterContainer/VBoxContainer/Quit

onready var paused : bool = false

var dialog_node 
#func _ready():
#	focus()
#func _process(_delta):
#	if paused:
#		focus()

#When the Pause Menu enters the level, we automatically hide it
func _unhandled_input(event):
	if event.is_action_pressed("pause") and GAME.dialog_shown == false:
		paused = !paused
		self.is_paused = !is_paused

#func _process(_delta):
#	if Input.is_action_just_pressed("pause"):
#		if is_paused:
#			focus()
#		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_parent().get_tree().paused = is_paused
	visible = is_paused

func focus():
	resume.grab_focus()
#	restart.grab_focus()
#	quit.grab_focus()

func _on_Resume_pressed():
#	self.is_paused = false
	set_is_paused(false)

func _on_Quit_pressed():
	# Temporal solution for the whole app paused
	self.is_paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene(main_menu)
	#Pause menu parent is GUI, and the parent is level
#    get_parent().get_parent().get_tree().change_scene(main_menu)

func _on_Restart_pressed():
# warning-ignore:unused_variable
	var current_scene = get_tree().get_current_scene()
	get_tree().reload_current_scene()
#	get_parent().get_tree().
#	GAME.load_game()
