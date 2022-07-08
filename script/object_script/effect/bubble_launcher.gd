# 定点定时发射气泡
extends Node2D

export var offset :Vector2 = Vector2.ZERO
export var activate :bool = false
export var interval :float = 1
export var angle :float = -PI/2
export var layer :int = 1
export var bubble :PackedScene

func _ready() ->void:
	$Timer.wait_time = interval
	
func _process(_delta) ->void:
	if activate:
		if $Timer.is_stopped():
			$Timer.start()
	else:
		$Timer.stop()

func _on_Timer_timeout() ->void:
	var new: Node2D = bubble.instance()
	new.position = position + offset
	new.direction = Vector2.RIGHT.rotated(angle)
	var parent :Node = Berry.get_parent_ext(self,layer)
	parent.add_child(new)
