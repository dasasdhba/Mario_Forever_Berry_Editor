# 使玩家死亡，需要设置父节点为 Area2D
extends Node
export var force: bool = false

onready var parent :Area2D = get_parent()

func _physics_process(_delta) ->void:
	for i in parent.get_overlapping_areas():
		if i.has_method("_player"):
			i.get_parent().player_death(force)
