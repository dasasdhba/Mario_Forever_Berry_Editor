extends Node2D

export var start_pipe :bool = false

var parent :Node = null
	
func _pipe_exit(i :Node, start :bool = false) ->void:
	var gdir :Vector2 = Berry.get_global_direction(i,i.gravity_direction)
	var angle :float = wrapf(gdir.angle()-global_rotation,-PI,PI)
	# 下
	if abs(angle) <= PI/4:
		var new_pos :Vector2
		if i.state == 0:
			new_pos = global_position + $PosUpSmall.relative(false,false,true)
		else:
			new_pos = global_position + $PosUpBig.relative(false,false,true)
		i.position = Berry.get_xform_position(i,new_pos) - i.pipe_vertical*i.gravity_direction
		i.player_pipe_exit(1,start)
	# 上
	elif abs(angle) >= 3*PI/4:
		var new_pos :Vector2 = global_position + $PosDown.relative(false,false,true)
		i.position = Berry.get_xform_position(i,new_pos) + i.pipe_vertical*i.gravity_direction
		i.player_pipe_exit(3,start)
	# 右
	elif angle >= PI/4 && angle <= 3*PI/4:
		var new_pos :Vector2 = global_position + $PosSide.relative(false,false,true)
		i.position = Berry.get_xform_position(i,new_pos) - i.pipe_horizontal*i.gravity_direction.tangent()
		i.player_pipe_exit(0,start)
	# 左
	else:
		var new_pos :Vector2 = global_position + $PosSide.relative(false,true,true)
		i.position = Berry.get_xform_position(i,new_pos) + i.pipe_horizontal*i.gravity_direction.tangent()
		i.player_pipe_exit(2,start)
		
func _ready() ->void:
	if start_pipe:
		var scene :Node = Berry.get_scene(self)
		var rect :Rect2 = Rect2(position - 32*Vector2.ONE,64*Vector2.ONE)
		for i in scene.current_player:
			var i_pos :Vector2 = Berry.get_xform_position(self,i.global_position)
			if rect.has_point(i_pos):
				i.pipe = 5
				if i.global == null:
					i.global_inherit()
				_pipe_exit(i,true)

func _physics_process(_delta) ->void:
	if parent == null:
		parent = get_parent()
	if !parent.has_method("_pipe_enter"):
		if !start_pipe:
			queue_free()
		return
	for i in parent.player:
		if i.pipe == 5:
			parent.player.erase(i)
			_pipe_exit(i)
