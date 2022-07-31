extends Area2D

export var speed_max :float = 50
export var acceleration :float = 155
export var deceleration :float = 155
export var activate_range :Vector2 = Vector2(64,64)

var direction :int = -1
var speed :float = 0
var move_dir :Vector2 = Vector2.LEFT

onready var parent :Node = get_parent()
onready var view :Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)

func _physics_process(delta :float) ->void:
	if !view.is_in_view(global_position,activate_range*scale):
		$AnimatedSprite.frame = 0
		return
	var p :Node = scene.get_player_nearest(self)
	var p_pos :Vector2 = Vector2.ZERO
	if p != null:
		p_pos = parent.global_transform.xform_inv(p.global_position)
		if position.direction_to(p_pos).dot(Vector2.DOWN.rotated(rotation).tangent()) > 0:
			direction = 1
		else:
			direction = -1
	var move :bool = p != null && p.move_direction == direction
	$AnimatedSprite.frame = move as int
	if move:
		if speed < speed_max:
			speed += acceleration * delta
		else:
			speed = speed_max
	else:
		if speed > 0:
			speed -= deceleration * delta
		else:
			speed = 0
			
	if p != null:
		move_dir = position.direction_to(p_pos)
	position += speed * delta * move_dir
