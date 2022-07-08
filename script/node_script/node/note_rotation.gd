# 旋转父节点
extends Node

export var rot_speed :float = 1000
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = 1

onready var parent :Node = get_parent()

func _process(delta) ->void:
	parent.rotation_degrees += rot_speed * direction * delta
