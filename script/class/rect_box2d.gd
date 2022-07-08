# RectCollision2D 使用的碰撞箱资源类型
tool
extends Node2D
class_name RectBox2D, "icon/rect_box2d.png"

export var disabled :bool = false
export var size: Vector2 = Vector2(32,32)

func _draw() ->void:
	if !Engine.editor_hint:
		return
	var col :Color = Color(0.5,0,0.5,0.3)
	if disabled:
		col = Color(0.5,0.5,0.5,0.5)
	draw_rect(Rect2(size/-2,size),col)
	
func _process(_delta) ->void:
	if Engine.editor_hint:
		update()

# 从 Shape2D 资源加载
func load_rect_shape(shape :RectangleShape2D) ->void:
	if shape == null:
		return
	size = 2*shape.extents

# 从 CollisionShape2D 资源加载，包括其 transform，disabled 情况
func load_collision_shape(col :CollisionShape2D) ->void:
	if col == null:
		return
	if col.shape is RectangleShape2D:
		Berry.transform_copy(self,col)
		load_rect_shape(col.shape)
		disabled = col.disabled

# 碰撞检测
func is_overlapping_with(box :RectBox2D, delta_pos :Vector2 = Vector2.ZERO) ->bool:
	if disabled || box.disabled:
		return false
	# 先用外接圆和内切圆粗略判定
	var delta_length :float = (global_position + delta_pos - box.global_position).length()
	var s: float = Vector2(size.x*global_scale.x,size.y*global_scale.y).length()/2
	var t: float = Vector2(box.size.x*box.global_scale.x,box.size.y*box.global_scale.y).length()/2
	if delta_length >= s + t:
		return false
	s = min(size.x*global_scale.x,size.y*global_scale.y)/2
	t = min(box.size.x*box.global_scale.x,box.size.y*box.global_scale.y)/2
	if delta_length < s + t:
		return true
	
	var ps :PoolVector2Array = get_global_point(self, delta_pos)
	var pt: PoolVector2Array = get_global_point(box)
	var inside_hint :bool = true
	for i in 4:
		var x: PoolIntArray = []
		var y: PoolIntArray = []
		for j in 4:
			var a: Rect2
			a.position = ps[i]
			a.end = ps[(i+1) % 4]
			var b: Rect2
			b.position = pt[j]
			b.end = pt[(j+1) % 4]
			var v: Vector2 = is_line_crossed_with(a,b)
			if v == Vector2.ZERO:
				return true
			if inside_hint:
				if v.x != 0 && v.x != INF:
					if x.empty():
						x.append(v.x as int)
					elif x.size() == 1 && v.x != x[0]:
						x.append(v.x as int)
				if v.y != 0 && v.y != INF:
					if y.empty():
						y.append(v.y as int)
					elif y.size() == 1 && v.y != y[0]:
						y.append(v.y as int)
		if x.size() != 2 && y.size() != 2:
			inside_hint = false
	return inside_hint
	
# 获取 global 意义下的四个点
static func get_global_point(box: RectBox2D, delta_pos :Vector2 = Vector2.ZERO) ->PoolVector2Array:
	var r: PoolVector2Array = []
	var x: float = box.size.x*box.global_scale.x
	var y: float = box.size.y*box.global_scale.y
	var p: Vector2
	for i in 4:
		match i:
			0:
				p = Vector2(x/-2,y/-2)
			1:
				p = Vector2(x/2,y/-2)
			2:
				p = Vector2(x/2,y/2)
			3:
				p = Vector2(x/-2,y/2)
		p.rotated(box.global_rotation)
		p += box.global_position + delta_pos
		r.append(p)
	return r
	
# 判断线段相交情况，0 表示相交，-1，1 表示交于线段的某一延长线，INF 表示平行或者重合
static func is_line_crossed_with(a :Rect2, b :Rect2) ->Vector2:
	var p1 :Vector2 = a.position
	var p2 :Vector2 = a.end
	var q1: Vector2 = b.position
	var q2: Vector2 = b.end
	var k1: float
	var k2: float
	if p1.x == p2.x:
		k1 = INF
	else:
		k1 = (p1.y-p2.y)/(p1.x-p2.x)
	if q1.x == q2.x:
		k2 = INF
	else:
		k2 = (q1.y-q2.y)/(q1.x-q2.x)
	if k1 == k2:
		return Vector2(INF,INF)
	var rx: int = 0
	var ry: int = 0
	var c :Vector2
	if k1 == INF:
		c.x = p1.x
		c.y = k2*(c.x-q1.x)+q1.y
	elif k2 == INF:
		c.x = q1.x
		c.y = k1*(c.x-p1.x)+p1.y
	else:
		c.x = (q1.y-p1.y+k1*p1.x-k2*q1.x)/(k1-k2)
		c.y = k1*(c.x-p1.x)+p1.y
	if c.x > min(max(p1.x,p2.x),max(q1.x,q2.x)):
		rx = 1
	elif c.x < max(min(p1.x,p2.x),min(q1.x,q2.x)):
		rx = -1
	if c.y > min(max(p1.y,p2.y),max(q1.y,q2.y)):
		ry = 1
	elif c.y < max(min(p1.y,p2.y),min(q1.y,q2.y)):
		ry = -1
	return Vector2(rx,ry)
