# 用于敌人互相碰撞转向，需要设置父节点为 Area2D
extends Node

export var layer :int = 2
export var disabled :bool = false

onready var parent :Area2D = get_parent()
onready var root :Node = Berry.get_parent_ext(self,layer)

func _ready() ->void:
	if !parent.is_connected("area_entered",self,"on_area_entered"):
		parent.connect("area_entered",self,"on_area_entered")

func on_area_entered(area :Area2D) ->void:
	if disabled:
		return
	if area.has_method("_enemy_turn"):
		if area._enemy_turn():
			root.direction *= -1
