extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation = $AnimationPlayer
onready var finish = $YouDiedPanel
onready var rematch = $YouDiedPanel/VBoxContainer/RematchButton
onready var change = $YouDiedPanel/VBoxContainer/ChangeCharacterButton
onready var menu = $YouDiedPanel/VBoxContainer/MenuButton

onready var main_screen = "res://gui/screens/main_menu/scenes/MainMenu.tscn"
onready var char_select = "res://worlds/local_pvp/char_select_pvp/scenes/CharSelectPVP.tscn"
onready var pvp = "res://worlds/local_pvp/scenes/local_pvp.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("background_fade_in")
	

func focus():
	rematch.grab_focus()
	change.grab_focus()
	menu.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RematchButton_pressed():
#	get_tree().change_scene(pvp)
	get_tree().reload_current_scene()


func _on_ChangeCharacterButton_pressed():
	get_tree().change_scene(char_select)


func _on_MenuButton_pressed():
	get_tree().change_scene(main_screen)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"background_fade_in":
			finish.visible = true
			focus()
			animation.play("panel_animation")
