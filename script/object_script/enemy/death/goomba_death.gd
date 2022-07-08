extends Node

export var score :int = 100

var once :bool = false

onready var parent: Node = get_parent()

func _on_attacked(atk :Array) ->void:
	if once:
		return
	once = true
	var death: Node = Lib.enemy_death.instance()
	Berry.transform_copy(death,parent)
	death.gravity_direction = parent.gravity_direction
	if atk[0] != "shell" && atk[0] != "star" && atk[0] != "lava":
		var s :Node = Lib.score.instance()
		s.score = score
		s.position = parent.position
		parent.get_parent().add_child(s)
	
	if atk[0] == "stomp":
		var spr: Sprite = $Sprite.duplicate()
		spr.visible = true
		death.add_child(spr)
		var shape :CollisionShape2D = parent.get_node("CollisionShape2D")
		death.add_child(shape.duplicate())
		death.get_node("Area2D").add_child(shape.duplicate())
	else:
		var spr: Sprite = parent.get_node("Sprite").duplicate()
		spr.remove_child(spr.get_node("Timer"))
		spr.flip_v = true
		death.add_child(spr)
		death.gravity = -350
	parent.get_parent().add_child(death)
	parent.queue_free()
