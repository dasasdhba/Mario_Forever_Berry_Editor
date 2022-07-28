tool
extends Node2D

export var radius :Vector2 = Vector2(0,50)
export var speed :float = 100
export var phase :float = 0
export var look_player :bool = true # 是否朝向马里奥
export var preview :bool = false
export var preview_color :Color = Color(0,0,1,0.7)
export var brush_border :Rect2 = Rect2(-16,-16,32,48)
export var brush_offset :Vector2 = Vector2(16,25)

var delta_position :Vector2 = Vector2.ZERO
var direction :int = -1
var preview_phase :float = 0

onready var origin_position: Vector2 = position
onready var gravity_direction :Vector2 = Vector2.DOWN.rotated(rotation)
	
func _physics_process(delta :float) ->void:
	if Engine.editor_hint:
		if preview:
			preview_phase += speed * delta
		else:
			preview_phase = 0
		update()
		return
			
	delta_position = -position
	
	# 运动
	phase += speed * delta
	phase = wrapf(phase,0,360)
	var new_pos :Vector2 = Vector2(radius.x*cos(deg2rad(phase)),radius.y*sin(deg2rad(phase)))
	position = origin_position + new_pos.rotated(rotation)
	
	# 朝向
	if !look_player:
		if phase > 180 && phase < 360:
			direction = 1
		else:
			direction = -1
	$AnimatedSprite.look_player = look_player
		
	delta_position += position
	
func _draw() ->void:
	if !Engine.editor_hint:
		return
	# 本体
	if preview:
		var new_pos :Vector2 = Vector2(radius.x*cos(deg2rad(phase + preview_phase)),radius.y*sin(deg2rad(phase + preview_phase)))
		var tex :Texture = $AnimatedSprite.frames.get_frame("default",$AnimatedSprite.frame)
		draw_texture(tex,new_pos-tex.get_size()/2,Color(1,1,1,0.7))
		
	# 轨迹
	if radius.x == 0 && radius.y == 0:
		return
	if radius.x == 0:
		draw_line(-Vector2(0,radius.y),Vector2(0,radius.y),preview_color)
		return
	if radius.y == 0:
		draw_line(-Vector2(radius.x,0),Vector2(radius.x,0),preview_color)
		return
	var s :Vector2 = Vector2.ONE
	var r :float = 0
	if radius.x > radius.y:
		r = radius.y
		s.x = radius.x/radius.y
	else:
		r = radius.x
		s.y = radius.y/radius.x
	draw_set_transform(Vector2.ZERO,0,s)
	draw_arc(Vector2.ZERO,r,0,PI,32,preview_color,1,true)
	draw_arc(Vector2.ZERO,-r,0,PI,32,preview_color,1,true)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
