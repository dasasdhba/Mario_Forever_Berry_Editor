# 需要设置父节点为 Gravity，除去重力反方向外的出界销毁(玩家武器)
extends Node

export var border :float = 16

onready var parent :Gravity = get_parent()
onready var view: Node = Berry.get_view(self)

func _physics_process(_delta) ->void:
	var pos :Vector2 = parent.global_position
	var s :Vector2 = parent.scale
	var gdir :Vector2 = Berry.get_global_direction(parent,parent.gravity_direction)
	var angle :float = rad2deg(gdir.angle())
	var c :bool
	if angle >= 45 && angle <= 135:
		c =  view.is_in_view_left(pos,border*s) && view.is_in_view_right(pos,border*s) && view.is_in_view_bottom(pos,border*s)
	elif angle >= 135 || angle <= -135:
		c =  view.is_in_view_left(pos,border*s) && view.is_in_view_top(pos,border*s) && view.is_in_view_bottom(pos,border*s)
	elif angle >= -135 && angle <= -45:
		c =  view.is_in_view_left(pos,border*s) && view.is_in_view_right(pos,border*s) && view.is_in_view_top(pos,border*s)
	else:
		c =  view.is_in_view_bottom(pos,border*s) && view.is_in_view_right(pos,border*s) && view.is_in_view_top(pos,border*s)
	if !c:
		parent.queue_free()
