extends Node

export var score :int = 100

onready var parent: Node = get_parent()

func _on_attacked(atk :Array) ->void:
	if parent.death:
		return
	var death: Node = Lib.enemy_death.instance()
	Berry.transform_copy(death,parent)
	death.gravity_direction = parent.gravity_direction
	if atk[0] != "shell" && atk[0] != "star" && atk[0] != "lava":
		var s :Node = Lib.score.instance()
		s.score = score
		s.position = parent.position
		parent.get_parent().add_child(s)
	
	var spr: AnimatedSprite = parent.get_node("Animation/Head").duplicate()
	spr.speed_scale = 0
	spr.flip_v = true
	death.add_child(spr)
	spr = parent.get_node("Animation/Body").duplicate()
	spr.speed_scale = 0
	spr.flip_v = true
	death.add_child(spr)
	parent.get_parent().add_child(death)
	parent.death = true
