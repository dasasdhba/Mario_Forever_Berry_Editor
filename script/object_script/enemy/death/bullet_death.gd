extends Node

export var score :int = 100

var once: bool = false

onready var parent: Node = get_parent()

func _on_attacked(_atk :Array) ->void:
	if once:
		return
	once = true
	
	var s :Node = Lib.score.instance()
	s.score = score
	s.position = parent.position
	parent.get_parent().add_child(s)
	
	var death: Node = Lib.enemy_death.instance()
	Berry.transform_copy(death,parent)
	death.gravity_direction = Vector2.DOWN
	var spr: Sprite = $Sprite.duplicate()
	spr.visible = true
	spr.flip_h = parent.direction == -1
	death.add_child(spr)
	death.speed = parent.speed * parent.direction * cos(parent.rotation)
	parent.get_parent().add_child(death)
	parent.queue_free()
