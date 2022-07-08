# 需要设置父节点为 Gravity，重力方向出界销毁
extends Node

export var border :float = 48

onready var parent :Gravity = get_parent()
onready var view: Node = Berry.get_view(self)

func _physics_process(_delta) ->void:
	var gdir :Vector2 = Berry.get_global_direction(parent,parent.gravity_direction)
	if !view.is_in_limit_direction(parent.global_position,border*parent.scale,gdir):
		parent.queue_free()
