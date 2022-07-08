tool
extends Area2D

export var speed :float = 50
export var radius_speed :float = 250
export var radius :float = 192
export var phase :float = 0
export var preview: bool = false
export var preview_color :Color = Color(1,1,1,0.7)

var current_radius :float
var r_dir :int = -1
var origin_position :Vector2
var once :bool = false

var preview_phase :float
var preview_dir :int = 1
var preview_radius :float = 0
	
func _draw() ->void:
	if !Engine.editor_hint:
		return
	var tex: Texture = $AnimatedSprite.frames.get_frame("default",$AnimatedSprite.frame)
	var r :float = radius - preview_radius
	var p :float = phase + preview_phase
	var pos :Vector2 = Vector2(r*cos(deg2rad(p)),r*sin(deg2rad(p)))
	draw_texture(tex,pos - tex.get_size()/2)
	draw_arc(Vector2.ZERO,radius,0,PI,32,preview_color,1,true)
	draw_arc(Vector2.ZERO,-radius,0,PI,32,preview_color,1,true)
	
func _ready() ->void:
	if !Engine.editor_hint:
		current_radius = radius
		origin_position = position
		$AnimatedSprite.visible = true

func _physics_process(delta) ->void:
	if Engine.editor_hint:
		if preview:
			preview_phase += speed * delta
			preview_radius += radius_speed * preview_dir * delta
			if preview_dir == -1:
				if preview_radius <= 0:
					preview_radius = 0
					preview_dir = 1
			elif preview_radius >= radius:
				preview_radius = radius
				preview_dir = -1
		else:
			preview_radius = 0
			preview_phase = 0
			preview_dir = 1
		update()
		return
	if !once:
		var center :Node = $RotoCenter
		remove_child(center)
		Berry.transform_copy(center,self)
		var parent :Node = get_parent()
		parent.add_child(center)
		parent.move_child(center,0)
		once = true
	current_radius += r_dir * radius_speed * delta
	if r_dir == -1:
		if current_radius <= 0:
			current_radius = 0
			r_dir = 1
	elif current_radius >= radius:
		current_radius = radius
		r_dir = -1
	phase += speed * delta
	phase = Berry.mod_range(phase,0,360)
	var new_pos :Vector2 = Vector2(current_radius*cos(deg2rad(phase)),current_radius*sin(deg2rad(phase)))
	position = origin_position + new_pos.rotated(rotation)
	
