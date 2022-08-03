tool
extends Node2D

export var exit_path :NodePath = @"" # 为空则检测子节点
export var preview :bool = true
export var preview_color :Color = Color(0,0.5,0,0.7)
export var brush_border :Rect2 = Rect2(-32,-32,64,64)
export var brush_offset :Vector2 = Vector2(0,0)

var player :Array = []
	
# 用于标识
func _pipe_enter() ->void:
	pass
	
func _ready() ->void:
	if Engine.editor_hint:
		return
	if !exit_path.is_empty():
		var exit :Node = get_node(exit_path)
		if exit.has_method("_pipe_exit"):
			exit.parent = self

func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		update()
		return
	# 上下
	for i in $AreaCenter.get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.pipe > 0:
				return
			var gdir :Vector2 = Berry.get_global_direction(p,p.gravity_direction)
			var angle :float = wrapf(gdir.angle()-global_rotation,-PI,PI)
			# 下
			if abs(angle) <= PI/4:
				if p.is_on_floor() && p.down_key:
					var new_pos :Vector2 = global_position + $PosDown.relative(false,false,true)
					p.position = Berry.get_xform_position(p,new_pos)
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
					p.position = Berry.get_xform_position(p,new_pos)
					p.player_pipe_enter(3)
					player.append(p)
	
	# 左右
	for i in $AreaSide.get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.pipe > 0:
				return
			var gdir :Vector2 = Berry.get_global_direction(p,p.gravity_direction)
			var angle :float = wrapf(gdir.angle()-global_rotation,-PI,PI)
			# 右
			if angle >= PI/4 && angle <= 3*PI/4:
				if p.is_on_floor() && $AreaBottom.get_overlapping_areas().has(i) && p.right_key && !p.left_key:
					var new_pos :Vector2 = global_position + $PosSide.relative(false,false,true)
					p.position = Berry.get_xform_position(p,new_pos)
					p.player_pipe_enter(0)
					player.append(p)
			# 左
			elif angle <= -PI/4 && angle >= -3*PI/4:
				if p.is_on_floor() && $AreaTop.get_overlapping_areas().has(i) && p.left_key && !p.right_key:
					var new_pos :Vector2 = global_position + $PosSide.relative(false,true,true)
					p.position = Berry.get_xform_position(p,new_pos)
					p.player_pipe_enter(2)
					player.append(p)

func _draw() ->void:
	if !Engine.editor_hint || !preview:
		return
	var exit :Node = null
	if !exit_path.is_empty():
		var node :Node = get_node(exit_path)
		if node.has_method("_pipe_exit"):
			exit = node
	if exit == null:
		for i in get_children():
			if i.has_method("_pipe_exit"):
				exit = i
				break
	if exit != null:
		var e_pos :Vector2 = get_parent().global_transform.affine_inverse().xform(exit.global_position) - position
		draw_set_transform(Vector2.ZERO,-rotation,Vector2(1/scale.x,1/scale.y))
		draw_line(Vector2.ZERO,e_pos,preview_color,2)
