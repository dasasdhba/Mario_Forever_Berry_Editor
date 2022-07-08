extends Node2D

export var brush_border :Rect2 = Rect2(-32,-32,64,64)
export var brush_offset :Vector2 = Vector2(0,0)

var player :Array = []

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
# 用于标识
func _pipe_enter() ->void:
	pass

func _physics_process(_delta) ->void:
	# 上下
	for i in $AreaCenter.get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.pipe > 0:
				return
			var gdir :Vector2 = Berry.get_global_direction(p,p.gravity_direction)
			var angle :float = Berry.mod_range(gdir.angle()-global_rotation,-PI,PI)
			# 下
			if abs(angle) <= PI/4:
				if p.is_on_floor() && p.down_key:
					var new_pos :Vector2 = global_position + $PosDown.relative(false,false,true)
					p.position = p.get_parent().global_transform.xform_inv(new_pos)
					p.player_pipe_enter(1)
					player.append(p)
			# 上
			elif abs(angle) >= 3*PI/4:
				if !p.is_on_floor() && p.gravity <= 0 && p.up_key:
					var new_pos :Vector2
					if p.state == 0:
						new_pos = global_position + $PosUpSmall.relative(false,false,true)
					else:
						new_pos = global_position + $PosUpBig.relative(false,false,true)
					p.position = p.get_parent().global_transform.xform_inv(new_pos)
					p.player_pipe_enter(3)
					player.append(p)
	
	# 左右
	for i in $AreaSide.get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.pipe > 0:
				return
			var gdir :Vector2 = Berry.get_global_direction(p,p.gravity_direction)
			var angle :float = Berry.mod_range(gdir.angle()-global_rotation,-PI,PI)
			# 右
			if angle >= PI/4 && angle <= 3*PI/4:
				if p.is_on_floor() && $AreaBottom.get_overlapping_areas().has(i) && p.right_key && !p.left_key:
					var new_pos :Vector2 = global_position + $PosSide.relative(false,false,true)
					p.position = p.get_parent().global_transform.xform_inv(new_pos)
					p.player_pipe_enter(0)
					player.append(p)
			# 左
			elif angle <= -PI/4 && angle >= -3*PI/4:
				if p.is_on_floor() && $AreaTop.get_overlapping_areas().has(i) && p.left_key && !p.right_key:
					var new_pos :Vector2 = global_position + $PosSide.relative(false,true,true)
					p.position = p.get_parent().global_transform.xform_inv(new_pos)
					p.player_pipe_enter(2)
					player.append(p)
