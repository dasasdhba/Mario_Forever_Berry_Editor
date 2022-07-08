# 匀速 sprout，需要父节点调用 start
extends Node

export var out_speed :float = 50
var out_dir :Vector2 
var out_height :float
var out_origin :Vector2
var sprout :bool = false
var temp: bool
onready var parent :Node = get_parent()

# 开始
func start(dir :Vector2,height :float) ->void:
	out_dir = dir
	out_height = height
	out_origin = parent.position
	temp = parent.show_behind_parent
	parent.show_behind_parent = true
	sprout = true

func _physics_process(delta) ->void:
	if sprout:
		parent.position += out_speed*out_dir * delta
		if parent.position.distance_to(out_origin) >= out_height:
			sprout = false
			parent.show_behind_parent = temp
			var root :Node = parent.get_parent()
			parent.position += root.position
			parent.scale *= root.scale
			parent.rotation += root.rotation
			root.remove_child(parent)
			root.get_parent().add_child(parent)
			queue_free()
