# 食人花出水管禁用
extends Area2D

onready var parent :Node = get_parent()

func _ready() ->void:
	var length :float = (max(0,parent.stem_count)*16+32)
	$CollisionShape2D.position.y = length/2
	$CollisionShape2D.shape.extents.y = length/2 + 16

func _physics_process(_delta) ->void:
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.pipe > 5:
				parent.state = 2
				parent.pos = parent.height*parent.scale.y
				parent.r_time = 0
				break
