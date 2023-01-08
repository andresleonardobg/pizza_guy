class_name Character
extends KinematicBody2D

export var velocity: = 15000.0
var gravity: = 1000.0
var jump: = 18000.0
var move: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		move.y += gravity * delta

	move = move_and_slide(move, Vector2.UP)
