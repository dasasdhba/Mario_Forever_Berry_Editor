# 获取 vn
extends Node

onready var parent: Node = get_parent()

func get_bonus(player :Node) ->void: 
	if player.pipe || player.clear:
		return
	player.player_death(parent.force)
	var new :Node = Lib.boom.instance()
	new.position = parent.position
	new.scale = parent.scale
	parent.get_parent().add_child(new)
	parent.queue_free()
