extends Node2D

enum PopupIds{
	SHOW_LAST_MOUSE_POSITION = 100,
	SAY_HI,
}
var _last_mouse_position

onready var _pp = $PopupPanel
onready var yes = $PopupPanel/VBoxContainer2/HBoxContainer/YesBtn
onready var no= $PopupPanel/VBoxContainer2/HBoxContainer2/NoBtn

func _ready():
	no.grab_focus()
	yes.grab_focus()
	_pp.popup()
	


func _on_NoBtn_pressed():
	_pp.hide()


func _on_YesBtn_pressed():
	get_tree().quit()
