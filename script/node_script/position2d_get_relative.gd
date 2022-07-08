extends Position2D

export var layer :int = 1
onready var parent :Node = Berry.get_parent_ext(self,layer)

# 以父节点的缩放和旋转参数获取相对位置
func relative(flip_h :bool = false, flip_v :bool = false, global :bool = false) ->Vector2:
	var r :float = parent.rotation if !global else parent.global_rotation
	var s :Vector2 = parent.scale if !global else parent.global_scale
	var flip :Vector2 = Vector2(1-2*(flip_h as int),1-2*(flip_v as int))
	var rot :Vector2 = position.rotated(r)
	return Vector2(rot.x*s.x*flip.x,rot.y*s.y*flip.y)
