extends Area2D
var dialog = Dialogic

onready var PlayerGUIA = load("res://gui/huds/player-hud/scripts/PlayerGUI.gd")
var body_player
var dialog_active = false
var active = false

func _ready():
	connect("body_entered", self, '_on_NPC_body_entered')
	connect("body_exited", self, '_on_NPC_body_exited')

func _process(delta):
	$Question.visible = active
	detech_player_behind()

func _input(event):
	if get_node_or_null('DialogNode') == null and active:
		if event.is_action_pressed("ui_accept") and !dialog_active:
			get_tree().paused = true
			dialog = Dialogic.start('timeline-1')
			dialog.pause_mode = Node.PAUSE_MODE_PROCESS
			add_child(dialog)
			dialog_active = true
			get_tree().paused = false
			dialog.connect("dialogic_signal", self, "dialog_accepted")
			dialog.connect("timeline_end", self, "vanish")

func vanish(timeline_end):
	$AnimationPlayer.play("Vanish")
	
func dialog_accepted(dialogic_signal):
	print("You recovered 40 hp.")
	if body_player != null:
		body_player.health += 40
		body_player.pay()

func dialog_denied(dialogic_signal):
	print("You didn't buy anything")

func _on_NPC_body_entered(body):
	if body.is_in_group('Player'):
		body_player = body
		active = true
		
func _on_NPC_body_exited(body):
	if body.is_in_group('Player'):
		active = false

func detech_player_behind() -> void:
	if $detech_player.is_colliding():
		var body = $detech_player.get_collider()
		if body.is_in_group('Player'):
			scale.x *= -1
