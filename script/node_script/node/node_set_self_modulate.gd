extends Node

export var parent_layer :int = 1
export var target_layer :int = 2

onready var parent :Node = Berry.get_parent_ext(self,parent_layer)
onready var target :Node = Berry.get_parent_ext(self,target_layer)

func _process(_delta) ->void:
	parent.self_modulate = target.self_modulate
