tool
extends Sprite

export var overwrite :bool = false
export var speed :float = 50
export var preview: bool = false
export var preview_color :Color = Color(1,1,1,0.7)

var once :bool = false

# 用于标识
func _roto_center() ->void:
	pass
	
func _draw() ->void:
	if !Engine.editor_hint:
		return
	for i in get_children():
		if !i.has_method("_roto_disc"):
			continue
		var s :Vector2 = Vector2.ONE
		var radius :Vector2 = i.radius
		if !i.manual:
			radius = Vector2.ZERO.distance_to(i.position) * Vector2.ONE
		var r :float = 0
		if radius.x > radius.y && radius.y != 0:
			r = radius.y
			s.x = radius.x/radius.y
		elif radius.x != 0:
			r = radius.x
			s.y = radius.y/radius.x
		if r == 0:
			return
		draw_set_transform(Vector2.ZERO,0,s)
		draw_arc(Vector2.ZERO,r,0,PI,32,preview_color,1,true)
		draw_arc(Vector2.ZERO,-r,0,PI,32,preview_color,1,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	
func _physics_process(_delta) ->void:
	if Engine.editor_hint || once:
		update()
		for i in get_children():
			if i.has_method("_roto_disc"):
				i.preview = preview
				if overwrite:
					i.preview_speed = speed
				else:
					i.preview_speed = i.speed
		return

	for i in get_children():
		if i.has_method("_roto_disc"):
			i.activate = true
			if overwrite:
				i.speed = speed
	
	once = true
