extends Node

export var score :int = 200

var once :bool = false

onready var parent: Node = get_parent()

func _on_attacked(atk :Array) ->void:
	if once:
		return
	once = true
	if atk[0] != "shell" && atk[0] != "star" && atk[0] != "lava":
		var s :Node = Lib.score.instance()
		s.score = score
		s.position = parent.position
		parent.get_parent().add_child(s)

	parent.queue_free()
