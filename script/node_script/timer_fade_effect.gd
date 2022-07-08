# 定时创建 fade 特效
extends Timer

export var layer :int = 1

onready var parent :Node = get_parent()
onready var inherit :Node = Berry.get_parent_ext(parent,layer)
onready var root :Node = inherit.get_parent()

func _ready() ->void:
	if !is_connected("timeout",self,"on_timeout"):
		connect("timeout",self,"on_timeout")
		
func on_timeout() ->void:
	var new :Node = Lib.fade.instance()
	Berry.transform_copy(new,inherit)
	new.inherit(inherit)
	new.add_sprite(parent)
	root.add_child(new)
	root.move_child(new,inherit.get_index())
