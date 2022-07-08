# 与水接触相关的 signal，获取出入水的瞬间状态，需要设置父节点为 Area2D
extends Node

signal water_in_exact # 入水瞬间
signal water_out_exact # 出水瞬间

var reset :bool = true
var water :bool = false

onready var parent :Area2D = get_parent()

func on_area_entered(area) ->void:
	if reset:
		return
	if area is Water:
		if !water:
			water = true
			emit_signal("water_in_exact")

# 重置出入水瞬时状态
func reset_exact() ->void:
	if !parent.is_connected("area_entered",self,"on_area_entered"):
		parent.connect("area_entered",self,"on_area_entered")
	water = false
	for i in parent.get_overlapping_areas():
		if i is Water:
			water = true
			return
	
func disable() ->void:
	if parent.is_connected("area_entered",self,"on_area_entered"):
		parent.disconnect("area_entered",self,"on_area_entered")

func _physics_process(_delta) ->void:
	if reset:
		reset_exact()
		reset = false
	if water:
		for i in parent.get_overlapping_areas():
			if i is Water:
				return
		water = false
		emit_signal("water_out_exact")
