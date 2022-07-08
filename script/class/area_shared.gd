# 与父节点共享 CollisionShape2D
extends Area2D
class_name AreaShared, "icon/area_shared.png"

# 添加单个 CollisionShape2D
func add_shape(target :Node, force :bool = false) ->void:
	if !(target is CollisionShape2D || target is CollisionPolygon2D):
		return
	if has_node(target.name) && !force:
		return
	var new :CollisionShape2D = target.duplicate()
	add_child(new)

# 继承 CollisionObject2D 的 shape
func inherit(target :CollisionObject2D, override :bool = true) ->void:
	if override:
		clear()
	for i in target.get_shape_owners():
		var new = target.shape_owner_get_owner(i).duplicate()
		add_child(new)
	
# 清除全部 shape
func clear() ->void:
	for i in get_shape_owners():
		shape_owner_get_owner(i).queue_free()
