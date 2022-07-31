extends Node

onready var parent: Label = get_parent()
onready var red :Light2D = parent.get_node("LightRed")
onready var green :Light2D = parent.get_node("LightGreen")

func _process(_delta) ->void:
	green.visible = parent.text == "ON"
	red.visible = parent.text != "ON"
