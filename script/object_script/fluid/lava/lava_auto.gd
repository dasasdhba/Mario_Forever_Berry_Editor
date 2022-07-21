# 不支持旋转
tool
extends Area2D

export var lava_color :Color = Color(0.47,0,0,1)
export var preview_color :Color = Color(0.47,0,0,0.6)
export var preview :bool = true
export var preview_width :int = 1920
export var preview_height :int = 1080

var height :float
var target_height :float
var speed :float = 50

var view :Node

# 用于标识
func _lava_auto() ->void:
	pass

func _ready() ->void:
	if Engine.editor_hint:
		return
	view = Berry.get_view(self)
	height = position.y
	target_height = position.y
	var room :Node = Berry.get_room2d(self)
	if room != null:
		room.node_array.append(self)
	
func _draw() ->void:
	var tex :Texture = $AnimatedSprite.frames.get_frame("default",$AnimatedSprite.frame)
	if Engine.editor_hint && preview:
		# 编辑器预览
		var pos :Vector2 = get_global_mouse_position() - global_position
		var x :float = floor(pos.x/32)*32 - preview_width
		var y :float = max(pos.y-preview_height,0)
		var rect :Rect2 = Rect2(x, y+32, 2*preview_width, 2*preview_height)
		draw_rect(rect,preview_color)
		while x < pos.x + preview_width:
			draw_texture(tex,Vector2(x,0),Color(1,1,1,preview_color.a))
			x += 32
		return
	# 绘制水面
	var pos :Vector2 = view.current_border.position - global_position
	var x :float = floor(pos.x/32)*32 - 32
	var y :float = max(pos.y-32,0)
	var rect :Rect2 = Rect2(Vector2(x, y+32), view.current_border.size + 96*Vector2.ONE)
	draw_rect(rect,lava_color)
	if global_position.y <= view.current_border.end.y && global_position.y + 32 >= pos.y:
		while x < pos.x + view.current_border.size.x + 32:
			draw_texture(tex,Vector2(x,0),Color(1,1,1,lava_color.a))
			x += 32
		
func _physics_process(delta):
	update()
	if Engine.editor_hint:
		return
		
	# 判定范围
	$CollisionShape2D.shape.extents = view.current_limit.size
	$CollisionShape2D.position.x = (view.current_limit.position.x + view.current_limit.end.x)/2
	$CollisionShape2D.position.y = view.current_limit.size.y
	
	# 升降
	if target_height > height:
		position.y += speed * delta
		if position.y >= target_height:
			position.y = target_height
			height = target_height
	elif target_height < height:
		position.y -= speed * delta
		if position.y <= target_height:
			position.y = target_height
			height = target_height
