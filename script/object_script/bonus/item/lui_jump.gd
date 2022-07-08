extends Node2D

onready var parent :Node = get_parent()

func _physics_process(_delta) ->void:
	if parent.is_on_floor():
		$AudioJump.play()
