# 杂项函数与辅助函数
extends Node

var multiroom :bool = false # 是否开启多 room 管理基础功能

# 网格化 Vector2
func grid(vec :Vector2, sep :float = 16) ->Vector2:
	return sep*((vec/sep).round())

# 将向右的向量(Vector2.RIGHT)旋转指定角度并优化上下左右四个方向的精度
func vector2_rotate_degree(deg :float) ->Vector2:
	deg = wrapf(deg,0,360)
	match deg:
		0.0:
			return Vector2.RIGHT
		90.0:
			return Vector2.DOWN
		180.0:
			return Vector2.LEFT
		270.0:
			return Vector2.UP
	return Vector2.RIGHT.rotated(deg2rad(deg))

# pos,scale,rot 继承
func transform_copy(target :Node ,from :Node, delta_pos: Vector2 = Vector2.ZERO) ->void:
	if delta_pos == Vector2.ZERO:
		target.position = from.position
	else:
		target.position = from.position + Vector2(delta_pos.x*target.scale.x,delta_pos.y*target.scale.y).rotated(target.rotation)
	target.rotation = from.rotation
	target.scale = from.scale
	
# 获取全局坐标在特定节点所在坐标系下的坐标
func get_xform_position(node :Node2D, pos :Vector2) ->Vector2:
	var parent :Node = node.get_parent()
	if parent is Node2D:
		return parent.global_transform.affine_inverse().xform(pos)
	else:
		return pos

# 将相对坐标转为全局坐标
func get_global_position(node :Node2D, pos :Vector2) ->Vector2:
	var parent :Node = node.get_parent()
	if parent is Node2D:
		return parent.global_transform.basis_xform(pos)
	else:
		return pos

# 将相对坐标转为全局方向
func get_global_direction(node :Node2D, dir :Vector2) ->Vector2:
	return get_global_position(node,dir).normalized()

# 获取多层父节点
func get_parent_ext(node :Node ,layer :int = 1) ->Node:
	for i in layer:
		node = node.get_parent()
	return node

# 获取节点所在的 Room2D 父节点
func get_room2d(node :Node) ->Node:
	while !node is Room2D:
		node = node.get_parent()
		if node == null:
			return null
	return node
	
# 获取节点所在的 Scene 单例
func get_scene(node :Node) ->Node:
	if !multiroom:
		return Scene
	var room :Room2D = get_room2d(node)
	if room != null:
		return room.manager
	else:
		return Scene
		
# 获取节点所在的 ViewportControl 父节点
func get_viewport_control(node :Node) ->Node:
	while !node is ViewportControl:
		node = node.get_parent()
		if node == null:
			return null
	return node
		
# 获取节点所在的 View 单例
func get_view(node :Node) ->Node:
	if !multiroom:
		return View
	var view :ViewportControl = get_viewport_control(node)
	if view != null:
		return view.manager
	else:
		return View
	
# 获取随机数单例
func get_rand(node :Node) ->RandomNumberGenerator:
	var r :RandomNumberGenerator = RandomNumberGenerator.new()
	var room :Room2D = get_room2d(node)
	if room != null && room.random_seed != "":
		r.seed = hash(room.random_seed + node.name)
	else:
		r.randomize()
	return r

# Area2D 检测实心
func area2d_is_overlapping_with_solid(area :Area2D) ->bool:
	for i in area.get_overlapping_bodies():
		if (area.collision_layer & i.collision_mask) > 0:
			return true
	return false
	
# 获取 InputEventKey
func get_input_event_key(action :String) ->InputEventKey:
	for i in InputMap.get_action_list(action):
		if i is InputEventKey:
			return i
	return null
