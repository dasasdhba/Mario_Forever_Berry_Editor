tool
extends Sprite

export var number :int = 6
export var speed :float = 50
export var radius :Vector2 = Vector2(128,128)
export var phase :float = 0
export var preview :bool = false
export var preview_color :Color = Color(1,1,0,0.7)

var view_phase :float = 0

func _draw() ->void:
	if !Engine.editor_hint:
		return
		
	# 绘制龙总龟
	var tex :Texture = $Troopa.frames.get_frame("default", $Troopa.frame)
	for i in number:
		var p: float = phase + view_phase + i*360/number
		var new_pos :Vector2 = Vector2(radius.x*cos(deg2rad(p)),radius.y*sin(deg2rad(p)))
		draw_texture(tex,new_pos-tex.get_size()/2)
		
	# 绘制轨迹
	var s :Vector2 = Vector2.ONE
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

func _physics_process(delta) ->void:
	if !Engine.editor_hint:
		var parent: Node = get_parent()
		for i in number:
			var new :Node = $FlyTroopaGold.duplicate()
			new.visible = true
			Berry.transform_copy(new,self)
			new.speed = speed
			new.radius = radius
			new.phase = phase + i*360/number
			parent.add_child(new)
		queue_free()
		return
	if preview:
		view_phase += speed * delta
	else:
		view_phase = 0
	update()
