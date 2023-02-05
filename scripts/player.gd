extends "res://scripts/character.gd"

export (NodePath) var map
export (int) var off_set := 60
export (float) var time_animation := 1.0
onready var collision_anim := get_node("CollisionShape2D")
onready var animation_sprite := get_node("CollisionShape2D/AnimatedSprite")
onready var climbing_sprite := get_node("climbingSprite")
onready var ray_cast_climb := [get_node("CollisionShape2D/climb/over_the_head"), get_node("CollisionShape2D/climb/head")]
onready var animation_player_climb : = get_node("AnimationPlayer")

var walk : float
var has_gun : bool
var climb : bool = false
var side_of_look : bool
var key_is_pressed

enum States{
	WALK,
	SKATING,
	FLYING,
	CLIMB,
	CLIMBING
}

func _ready() -> void:
	add_climbing_r_animation()


func _physics_process(delta: float) -> void:

	climb = (ray_cast_climb[1].is_colliding() == true and ray_cast_climb[0].is_colliding() == false)
	side_of_look = true if get_local_mouse_position().x < 0 else false

	if climb:
		get_corner_to_climbing()
		gravity = 0
		move.y = 0
		
		if Input.is_action_just_pressed("up"):
			climbing_animation()
			
		else:
			animation_sprite.animation = "climb"

	walk = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# if has_gun:
	# 	animation_sprite.animation = "run_with_gun" if walk != 0 else "idle_with_gun"
	# else:

	
	if climb == false : 
		
		flip_player(side_of_look)
		
		if Input.is_action_pressed("down") : 
			animation_sprite.animation = "bend"
		elif walk != 0:
			animation_sprite.animation = "walk" 
		# elif Input.:
		# 	animation_sprite.animation = "idle"
	
	if Input.is_action_pressed("jump") and is_on_floor():
		move.y = -jump * delta
	
	move.x = walk * velocity * delta


#functions

func add_climbing_r_animation() -> void:
	var climbing_r = animation_player_climb.get_animation("climbing").duplicate()
	var position_sprite_anim = climbing_r.find_track("climbingSprite:position")
	var position_colli_anim = climbing_r.find_track("CollisionShape2D:position")
	
	#collision position
	for k in climbing_r.track_get_key_count(position_colli_anim):
		var x = -climbing_r.track_get_key_value(position_colli_anim, k).x
		var y = climbing_r.track_get_key_value(position_colli_anim, k).y
		climbing_r.track_set_key_value(position_colli_anim, k, Vector2(x,y))

	#sprite position
	for k in climbing_r.track_get_key_count(position_sprite_anim):
		var x = -climbing_r.track_get_key_value(position_sprite_anim, k).x
		var y = climbing_r.track_get_key_value(position_sprite_anim, k).y
		climbing_r.track_set_key_value(position_sprite_anim, k, Vector2(x,y))
	
	animation_player_climb.add_animation("climbing_r", climbing_r)

func flip_player(value: bool):
	climbing_sprite.flip_h = value
	animation_sprite.flip_h = value
	ray_cast_climb[0].cast_to.x = -20 if value else 20
	ray_cast_climb[1].cast_to.x = -20 if value else 20

func get_corner_to_climbing() -> void:
	var position_cell = ray_cast_climb[1].global_position - ray_cast_climb[1].get_collision_normal()
	var id_cell = get_node(map).world_to_map(position_cell)
	var p = get_node(map).map_to_world(id_cell)
	global_position.y = p.y + off_set

func climbing_animation() -> void:
	animation_sprite.visible = false
	climbing_sprite.visible = true
	animation_player_climb.play("climbing" if climbing_sprite.flip_h else "climbing_r")
		

func return_g() -> void:
	gravity = 1000.0
	animation_sprite.animation = "idle"


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	animation_sprite.visible = true
	climbing_sprite.visible = false
	animation_player_climb.clear_caches()
	self.global_position = collision_anim.global_position
	collision_anim.position = Vector2.ZERO
	return_g()
