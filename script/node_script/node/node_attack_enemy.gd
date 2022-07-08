# 攻击敌人，需要设置父节点为 Area2D
extends Node

export var type: String = "" # 攻击种类
export var layer :int = 2
export var disabled :bool  = false
onready var parent :Area2D = get_parent()
onready var root: Node = Berry.get_parent_ext(self,layer)

func _physics_process(_delta) ->void:
	if !disabled:
		if !parent.is_connected("area_entered",self,"attack_area"):
			parent.connect("area_entered",self,"attack_area")
	else:
		if parent.is_connected("area_entered",self,"attack_area"):
			parent.disconnect("area_entered",self,"attack_area")

func attack_area(area) ->void:
	if disabled:
		return
	if area.has_method("_enemy"):
		area.attacked.append([type,root])

# 手动实现
func attack() ->void:
	for i in parent.get_overlapping_areas():
		if i.has_method("_enemy"):
			i.attacked.append([type,root])
