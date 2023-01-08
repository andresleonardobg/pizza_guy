extends "res://scripts/character.gd"

onready var animation_sprite := get_node("AnimatedSprite")

var walk : float
var has_gun : bool

enum States{
	WALK,
	SKATING,
	FLYING,
	CLAMBING
}

func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:

	walk = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# if has_gun:
	# 	animation_sprite.animation = "run_with_gun" if walk != 0 else "idle_with_gun"
	# else:

	flip_player(true if get_local_mouse_position().x < 0 else false)

	animation_sprite.animation = "walk" if walk != 0 else "idle"

	if Input.is_action_pressed("up") and is_on_floor():
		move.y = -jump * delta
	
	move.x = walk * velocity * delta


#functions
func flip_player(value: bool):
	animation_sprite.flip_h = value
