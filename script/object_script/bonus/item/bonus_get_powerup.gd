# 获取状态补给
extends Node

onready var parent: Node = get_parent()

func get_bonus(player :Node) ->void:
	if player.pipe:
		return
	player.player_state_update(parent.state,parent.force)
	if parent.score > 0:
		var new :Node = Lib.score.instance()
		new.score = parent.score
		new.position = parent.position
		parent.get_parent().add_child(new)
	parent.queue_free()
