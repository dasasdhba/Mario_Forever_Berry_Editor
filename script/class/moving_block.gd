# 用于修正运动实心补正
extends KinematicBody2D
class_name MovingBlock, "icon/moving_block.png"

var col_origin :Array = []

func _ready() ->void:
	collision_origin_update()

# 存储 CollisionShape 的初始位置
func collision_origin_update() ->void:
	col_origin.clear()
	for i in get_shape_owners():
		col_origin.append(shape_owner_get_owner(i).position)
		
# 设置 CollisionShape 的位置
func set_collision_position(pos :Vector2 = Vector2.ZERO) ->void:
	var shape_owner :Array = get_shape_owners()
	for i in shape_owner.size():
		shape_owner_get_owner(shape_owner[i]).position = col_origin[i] + pos
