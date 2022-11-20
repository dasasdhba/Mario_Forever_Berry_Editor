# 无限平铺 Texture
tool
extends Node2D
class_name TextureTiled, "icon/texture_tiled.png"

export var texture :Texture = null
export var texture_scale :Vector2 = Vector2.ONE
enum SPACING {PIXEL, TEXTURE}
export(SPACING) var spacing_mode :int = SPACING.PIXEL
export var spacing :Vector2 = Vector2.ZERO
export var expand_h :bool = false # 若 Camera 的 scale 不为 1 或者在变化，则需要启用 auto_update
export var expand_v :bool = false
export var velocity :Vector2 = Vector2.ZERO
export var auto_update :bool = false

var draw_size :Vector2
var draw_gap :Vector2
var global_draw_size :Vector2
var global_tex_size :Vector2
var view :Node

func is_invalid() ->bool:
	return texture == null || scale.x == 0 || scale.y == 0 || texture_scale.x == 0 || texture_scale.y == 0

func update_draw_size() ->void:
	if is_invalid():
		draw_size = Vector2.ZERO
		draw_gap = Vector2.ZERO
		global_draw_size = Vector2.ZERO
		global_tex_size = Vector2.ZERO
		return
	
	var size :Vector2 = texture.get_size()
	draw_gap = spacing.abs()
	if spacing_mode == SPACING.TEXTURE:
		draw_gap.x *= size.x
		draw_gap.y *= size.y
	if !Engine.editor_hint && (expand_h || expand_v):
		var tex_size :Vector2 = Vector2(size.x*abs(texture_scale.x),size.y*abs(texture_scale.y)) + draw_gap
		global_tex_size = Berry.get_global_position(self,tex_size).abs()
		
		var border_size :Vector2 = view.current_border.size
		draw_size.x = tex_size.x * max(3,ceil(border_size.x/tex_size.x)+3) if expand_h else abs(scale.x)*(size.x+draw_gap.x)
		draw_size.y = tex_size.y * max(3,ceil(border_size.y/tex_size.y)+3) if expand_v else abs(scale.y)*(size.y+draw_gap.y)
	else:
		draw_size = Vector2(abs(scale.x)*(size.x+draw_gap.x),abs(scale.y)*(size.y+draw_gap.y))
	
	if !Engine.editor_hint:
		global_draw_size = Berry.get_global_position(self,draw_size)

func _ready() ->void:
	if Engine.editor_hint:
		return
	
	view = Berry.get_view(self)
	update_draw_size()

func _draw() ->void:
	if is_invalid():
		return
	var draw_rect :Rect2 = Rect2(Vector2.ZERO,draw_size)
	draw_rect.end.x *= sign(texture_scale.x)/abs(texture_scale.x)
	draw_rect.end.y *= sign(texture_scale.y)/abs(texture_scale.y)
	draw_set_transform(Vector2.ZERO,0,Vector2(abs(texture_scale.x)/scale.x,abs(texture_scale.y)/scale.y))
	if draw_gap == Vector2.ZERO:
		draw_texture_rect(texture,draw_rect,true)
	else:
		var gap :Vector2 = draw_gap
		if spacing_mode == SPACING.PIXEL:
			gap.x /= abs(texture_scale.x)
			gap.y /= abs(texture_scale.y)
		var rect_size :Vector2 = texture.get_size()
		var size :Vector2 = rect_size + gap
		rect_size.x *= sign(draw_rect.end.x)
		rect_size.y *= sign(draw_rect.end.y)
		var i :int = 0
		while i * size.x < abs(draw_rect.end.x):
			var j :int = 0
			while j * size.y < abs(draw_rect.end.y):
				var pos :Vector2 = Vector2(i * size.x, j * size.y)
				var rect :Rect2 = Rect2(pos, rect_size)
				draw_texture_rect(texture,rect,true)
				j += 1
			i += 1

func _process(_delta) ->void:
	if Engine.editor_hint:
		update_draw_size()
		update()
		return
	
	if auto_update:
		update_draw_size()
		update()

func _physics_process(delta) ->void:
	if Engine.editor_hint:
		return
	
	position += velocity * delta
	
	if draw_size.x == 0 || draw_size.y == 0:
		return
	
	if expand_h:
		var x :float = global_draw_size.x
		var unit :float = max(1,global_tex_size.x)
		if x > 0:
			while global_position.x + unit > view.current_border.position.x:
				global_position.x -= unit
			while global_position.x + x - unit < view.current_border.end.x:
				global_position.x += unit
		else:
			while global_position.x + x + unit > view.current_border.position.x:
				global_position.x -= unit
			while global_position.x - unit < view.current_border.end.x:
				global_position.x += unit
	if expand_v:
		var y :float = global_draw_size.y
		var unit :float = max(1,global_tex_size.y)
		if y > 0:
			while global_position.y + unit > view.current_border.position.y:
				global_position.y -= unit
			while global_position.y + y - unit < view.current_border.end.y:
				global_position.y += unit
		else:
			while global_position.y + y + unit > view.current_border.position.y:
				global_position.y -= unit
			while global_position.y - unit < view.current_border.end.y:
				global_position.y += unit