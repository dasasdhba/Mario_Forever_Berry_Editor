# 获取绿蘑菇
extends Node

export var life :int = 1

onready var parent: Node = get_parent()

func get_bonus(_player :Node) ->void: 
	var new :Node = Lib.life.instance()
	new.life = life
	new.position = parent.position
	parent.get_parent().add_child(new)
	parent.queue_free()
