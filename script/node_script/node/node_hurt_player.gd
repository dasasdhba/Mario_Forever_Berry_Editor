# 使玩家受伤，需要设置父节点为 Area2D
extends Node
export var attack :int = 1
export var force: bool = false

signal player_hurt

onready var parent :Area2D = get_parent()

func _physics_process(_delta) ->void:
	if attack <= 0:
		return
	for i in parent.get_overlapping_areas():
		if i.has_method("_player"):
			i.get_parent().player_hurt(attack,force)
			emit_signal("player_hurt")
