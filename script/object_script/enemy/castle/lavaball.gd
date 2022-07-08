tool
extends Area2D

export var first_time :float = 3
export var wait_time :float = 2
export var move_time :float = 2
export var height :float = 256
export var rotate_speed :float = 750

export var preview_color :Color = Color(1,0,0,0.7)

onready var parent :Node = get_parent()
onready var origin_position :Vector2 = position

var rot :float = 0
var timer :float = 0
var first :bool = false
var move :bool = false
var speed :float = 0
var acc :float = 0

func _ready() ->void:
	if Engine.editor_hint:
		return
	visible = false
	$Hurt.attack = -1

func _draw() ->void:
	if !Engine.editor_hint:
		return
	if height > 0:
		draw_line(Vector2.ZERO,Vector2(0,-height),preview_color)
	
func _physics_process(delta) ->void:
	if Engine.editor_hint:
		update()
		return
	if !move:
		var launch :bool = false
		timer += delta
		if !first:
			if timer >= first_time:
				timer = 0
				first = true
				launch = true
		elif timer >= wait_time:
			timer = 0
			launch = true
		if launch:
			$AnimatedSprite.rotation = 0
			move = true
			speed = -4*height/move_time
			acc = 8*height/(move_time*move_time)
			visible = true
			$Hurt.attack = 1
	else:
		speed += acc * delta
		position += speed * delta * Vector2.DOWN.rotated(rotation)
		if speed > 0:
			if $AnimatedSprite.rotation_degrees < 180:
				$AnimatedSprite.rotation_degrees += rotate_speed * delta
			else:
				$AnimatedSprite.rotation_degrees = 180
		if speed > 4*height/move_time:
			position = origin_position
			move = false
			visible = false
			$Hurt.attack = -1
			var spray :Node = Lib.lava_spray.instance()
			Berry.transform_copy(spray,self)
			parent.add_child(spray)
			
