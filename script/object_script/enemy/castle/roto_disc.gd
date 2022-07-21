tool
extends Area2D

export var speed :float = 50
export var manual :bool = false
export var radius :Vector2 = Vector2(160,160)
export var phase :float = 0

var activate :bool = false
var preview :bool = false
var preview_speed :float = 0
var preview_phase :float = 0

# 用于标识
func _roto_disc() ->void:
	pass

func _physics_process(delta :float) ->void:
	if Engine.editor_hint:
		editor_event(delta)
		return
			
	if !activate:
		return
	phase += speed * delta
	phase = wrapf(phase,0,360)
	position = Vector2(radius.x*cos(deg2rad(phase)),radius.y*sin(deg2rad(phase)))

func editor_event(delta :float) ->void:
	var parent :Node = get_parent()
	if !parent.has_method("_roto_center"):
		return
		
	if preview:
		preview_phase += preview_speed * delta
		position = Vector2(radius.x*cos(deg2rad(phase + preview_phase)),radius.y*sin(deg2rad(phase + preview_phase)))
	else:
		if preview_phase != 0:
			preview_phase = 0
			position = Vector2(radius.x*cos(deg2rad(phase)),radius.y*sin(deg2rad(phase)))
		if !manual:
			radius = Vector2.ZERO.distance_to(position) * Vector2.ONE
			phase = rad2deg(Vector2.ZERO.direction_to(position).angle())
		else:
			position = Vector2(radius.x*cos(deg2rad(phase)),radius.y*sin(deg2rad(phase)))
		
	return
