extends Node

onready var parent :Node = get_parent()
onready var root :Node = parent.get_parent()

func hit_coin() ->void:
	for i in parent.get_overlapping_areas():
		if i.has_method("get_coin"):
			var ip :Node = i.get_parent()
			ip.remove_child(i)
			root.add_child(i)
			i._item()
