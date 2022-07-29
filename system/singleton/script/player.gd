# 用于管理玩家的全局变量
extends Node

export var global_var_name :Array = [
	"state"
]
export var global_var_value :Array = [
	0
]

var player_node :Node = null

onready var default_value :Array = global_var_value.duplicate()

func reset(apply :bool = true) ->void:
	global_var_value = default_value.duplicate()
	if apply:
		inherit()

func inherit() ->void:
	if is_instance_valid(player_node):
		for i in global_var_name.size():
			player_node.set(global_var_name[i],global_var_value[i])

func update() ->void:
	if is_instance_valid(player_node):
		for i in global_var_name.size():
			var new = player_node.get(global_var_name[i])
			if new != null:
				global_var_value[i] = new

func _physics_process(_delta) ->void:
	update()
