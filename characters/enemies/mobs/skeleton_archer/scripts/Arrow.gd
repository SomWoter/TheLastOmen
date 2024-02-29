class_name Arrow
extends Area2D

const SPEED = 250
var velocity = Vector2()
var direction = 1
onready var animatedSprite = $AnimatedSprite

export var arrow_damage = 10

func _ready():
	pass
	
func set_arrow_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true
#	else:
#		animatedSprite.flip_h = false
	
func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
	animatedSprite.play("shoot")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Arrow_body_entered(body):
	
	if body.is_in_group("Player"):
		body.damage_ctrl(arrow_damage)
		queue_free()
	elif body.is_in_group("Wall"):
		queue_free()
#	elif body.is_in_group("Minotaur"):
#		body.damage_ctrl(arrow_damage)
#		queue_free()
