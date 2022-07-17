extends Node2D

export var brush_border :Rect2 = Rect2(-32,-32,64,64)
export var brush_offset :Vector2 = Vector2(0,0)

var parent :Node = null

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
func _pipe_exit() ->void:
	pass

func _physics_process(_delta) ->void:
	if parent == null:
		parent = get_parent()
	if !parent.has_method("_pipe_enter"):
		queue_free()
	for i in parent.player:
		if i.pipe == 5:
			parent.player.erase(i)
			var gdir :Vector2 = Berry.get_global_direction(i,i.gravity_direction)
			var angle :float = Berry.mod_range(gdir.angle()-global_rotation,-PI,PI)
			# 下
			if abs(angle) <= PI/4:
				var new_pos :Vector2
				if i.state == 0:
					new_pos = global_position + $PosUpSmall.relative(false,false,true)
				else:
					new_pos = global_position + $PosUpBig.relative(false,false,true)
				i.position = i.get_parent().global_transform.xform_inv(new_pos) - i.pipe_vertical*i.gravity_direction
				i.player_pipe_exit(1)
			# 上
			elif abs(angle) >= 3*PI/4:
				var new_pos :Vector2 = global_position + $PosDown.relative(false,false,true)
				i.position = i.get_parent().global_transform.xform_inv(new_pos) + i.pipe_vertical*i.gravity_direction
				i.player_pipe_exit(3)
			# 右
			elif angle >= PI/4 && angle <= 3*PI/4:
				var new_pos :Vector2 = global_position + $PosSide.relative(false,false,true)
				i.position = i.get_parent().global_transform.xform_inv(new_pos) - i.pipe_horizontal*i.gravity_direction.tangent()
				i.player_pipe_exit(0)
			# 左
			else:
				var new_pos :Vector2 = global_position + $PosSide.relative(false,true,true)
				i.position = i.get_parent().global_transform.xform_inv(new_pos) + i.pipe_horizontal*i.gravity_direction.tangent()
				i.player_pipe_exit(2)
				
