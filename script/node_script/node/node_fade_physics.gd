# 物理帧创建 fade 特效
extends Node

export var layer :int = 1
export var z_index_override :bool = false
export var z_index = 0

onready var parent :Node = get_parent()
onready var inherit :Node = Berry.get_parent_ext(parent,layer)
onready var root :Node = inherit.get_parent()
		
func _physics_process(_delta) ->void:
	var new :Node = Lib.fade.instance()
	Berry.transform_copy(new,inherit)
	if z_index_override:
		new.z_index = z_index
	new.inherit(inherit)
	new.add_sprite(parent)
	root.add_child(new)
	root.move_child(new,inherit.get_index())
