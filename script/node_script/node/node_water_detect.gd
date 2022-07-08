# 需要设置父节点为 Area2D
extends Node

var water :bool = false
onready var parent :Area2D = get_parent()

# 检测是否在水中
func is_in_water() ->bool:
	return water

func _ready() ->void:
	if !parent.is_connected("area_entered",self,"on_area_entered"):
		parent.connect("area_entered",self,"on_area_entered")

func on_area_entered(area) ->void:
	if area is Water:
		water = true
		
func _physics_process(_delta) ->void:
	if water:
		for i in parent.get_overlapping_areas():
			if i is Water:
				return
		water = false
