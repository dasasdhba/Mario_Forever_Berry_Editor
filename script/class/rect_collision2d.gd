# 简易矩形碰撞检测，需要设置 RectBox2D 为子节点
# _ready 函数中必须调用一次 rect_init()
extends Node2D
class_name RectCollision2D, "icon/rect_collision2d.png"

# 需要检测的 RectCollision2D 节点的碰撞标识名，为空不能被检测
export var collision_name :String = ""
export var collision_layer :int = 0 # 图层
var rect_box: Array # RectBox2D 子节点

func _ready() ->void:
	rect_init()

# 初始化
func rect_init(update :bool = true) ->void:
	if collision_name != "":
		add_to_group("_rect_col2d_"+collision_name)
	if update:
		rect_update()
		
# 更新 RectBox2D
func rect_update() ->void:
	rect_box.clear()
	for i in get_children():
		if i is RectBox2D:
			rect_box.append(i)

# 清除 RectBox2D
func rect_clear() ->void:
	rect_box.clear()
	for i in get_children():
		if i is RectBox2D:
			i.queue_free()

# 从 CollisionObject2D 加载碰撞资源
func load_collision_object(target :CollisionObject2D, override :bool = false) ->void:
	if override:
		rect_clear()
	for i in target.get_shape_owners():
		var new :RectBox2D = RectBox2D.new() 
		new.load_collision_shape(target.shape_owner_get_owner(i))
		add_child(new)
		rect_box.append(new)
	
# 碰撞检测
func is_overlapping_with_rect(target_name :String, delta_pos :Vector2 = Vector2.ZERO) ->bool:
	if rect_box.empty():
		return false
	for i in get_tree().get_nodes_in_group("_rect_col2d_"+target_name):
		if i == self || collision_layer != i.collision_layer:
			continue
		for j in rect_box:
			for k in i.rect_box:
				if j.is_overlapping_with(k,delta_pos):
					return true
	return false

# 获取碰撞的对象
func get_overlapping_rect(target_name :String, delta_pos :Vector2 = Vector2.ZERO) ->Array:
	var r :Array = []
	if rect_box.empty():
		return r
	for i in get_tree().get_nodes_in_group("_rect_col2d_"+target_name):
		if i == self || collision_layer != i.collision_layer:
			continue
		for j in rect_box:
			var b :bool = false
			for k in i.rect_box:
				if j.is_overlapping_with(k,delta_pos):
					r.append(i)
					b = true
					break
			if b:
				break
	return r
