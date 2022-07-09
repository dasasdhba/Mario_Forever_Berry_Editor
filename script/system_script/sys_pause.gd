extends Node

onready var text:Label = $Control/Label

func _process(_delta):
	if Input.is_action_just_pressed("ui_pause"):
		var p = get_tree().paused
		get_tree().paused = !p
		p = get_tree().paused
		text.visible = p
