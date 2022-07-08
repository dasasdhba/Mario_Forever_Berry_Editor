extends Node

export var score :int = 200
export var gravity :float = -300

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
	
	var spr = $Sprite.duplicate()
	spr.visible = true
	death.add_child(spr)
	death.gravity = gravity
	parent.get_parent().add_child(death)
	parent.queue_free()
