# ViewportControl 管理，使用 Berry.get_view() 获取 View 单例
# 多 viewport 的情况请将不同的 View 单例绑定在不同的 ViewportControl 中
# 并且修改 Berry 单例的 multiroom 为 true
extends Node

var camera :Array
var current_border: Rect2 = Rect2(Vector2.ZERO,OS.get_window_size())
var current_limit :Rect2 = current_border
var current_zoom: Vector2 = Vector2.ONE
var trans:Transform2D # get_viewport_trans()

# 获取指定 viewport 的 current camera2D
func get_current_camera(viewport :Viewport = get_viewport()) ->Camera2D:
	for i in camera:
		if !is_instance_valid(i):
			continue
		if i is Camera2D && i.current && i.get_viewport() == viewport:
			return i
	return null
	
# 清除 camera 数组
func view_clear() ->void:
	camera.clear()

# 更新当前边界
func view_update(viewport :Viewport = get_viewport()) ->void:
	var c :Camera2D = null
	var i :int = 0
	while i < camera.size():
		if !is_instance_valid(camera[i]):
			camera.remove(i)
			continue
		if camera[i].current && camera[i].get_viewport() == viewport:
			c = camera[i]
		i += 1
	if c == null:
		return
	var center: Vector2 = c.get_camera_screen_center()
	var size: Vector2 = c.get_viewport_rect().size
	trans = c.get_viewport_transform()
	trans = trans.scaled(Vector2(1/trans.get_scale().x,1/trans.get_scale().y))
	var pos: Vector2 = Vector2(center.x - size.x*c.zoom.x/2,center.y - size.y*c.zoom.y/2)
	current_border = Rect2(pos,Vector2(size.x*c.zoom.x,size.y*c.zoom.y))
	current_limit = Rect2(c.limit_left,c.limit_top,c.limit_right-c.limit_left,c.limit_bottom-c.limit_top)
	current_zoom = c.zoom

# 计算给定位置是否在屏幕内
func is_in_view_left(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return trans.xform(pos).x > -size.x / current_zoom.x
	
func is_in_view_right(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return trans.xform(pos).x < (current_border.size.x + size.x) / current_zoom.x
	
func is_in_view_top(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return trans.xform(pos).y > -size.y / current_zoom.y
	
func is_in_view_bottom(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return trans.xform(pos).y < (current_border.size.y + size.y) / current_zoom.y
	
func is_in_view(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return is_in_view_left(pos,size) && is_in_view_right(pos,size) && is_in_view_top(pos,size) && is_in_view_bottom(pos,size)
	
func is_in_view_direction(pos :Vector2, size :Vector2 = Vector2.ZERO, dir = Vector2.UP) ->bool:
	var angle :float = rad2deg(dir.angle())
	var c :bool
	if angle >= 45 && angle <= 135:
		c = is_in_view_bottom(pos,size)
	elif angle >= 135 || angle <= -135:
		c = is_in_view_left(pos,size)
	elif angle >= -135 && angle <= -45:
		c = is_in_view_top(pos,size)
	else:
		c = is_in_view_right(pos,size)
	return c
	
# 计算给定位置是否在滚屏限制内
func is_in_limit_left(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return pos.x > current_limit.position.x - size.x*current_zoom.x
	
func is_in_limit_right(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return pos.x < current_limit.end.x + size.x*current_zoom.x
	
func is_in_limit_top(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return pos.y > current_limit.position.y - size.y*current_zoom.y
	
func is_in_limit_bottom(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return pos.y < current_limit.end.y + size.y*current_zoom.y
	
func is_in_limit(pos :Vector2, size :Vector2 = Vector2.ZERO) ->bool:
	return is_in_limit_left(pos,size) && is_in_limit_right(pos,size) && is_in_limit_top(pos,size) && is_in_limit_bottom(pos,size)
	
func is_in_limit_direction(pos :Vector2, size :Vector2 = Vector2.ZERO, dir = Vector2.UP) ->bool:
	var angle :float = rad2deg(dir.angle())
	var c :bool
	if angle >= 45 && angle <= 135:
		c = is_in_limit_bottom(pos,size)
	elif angle >= 135 || angle <= -135:
		c = is_in_limit_left(pos,size)
	elif angle >= -135 && angle <= -45:
		c = is_in_limit_top(pos,size)
	else:
		c = is_in_limit_right(pos,size)
	return c
