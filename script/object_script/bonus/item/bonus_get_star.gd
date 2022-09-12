# 获取无敌星
extends Node

onready var parent: Node = get_parent()

func get_bonus(player :Node) ->void: 
	if player.pipe || player.clear:
		return
	player.player_star()
	parent.queue_free()
