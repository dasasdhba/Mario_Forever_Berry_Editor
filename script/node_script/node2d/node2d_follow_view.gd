extends Node2D

onready var view :Node = Berry.get_view(self)

func _process(_delta) ->void:
	global_position = view.current_border.position
