# 用于石盾砸地特效
extends KinematicBody2D

export var direction :Vector2 = Vector2.DOWN
export var disabled :bool = false

var once :bool = false

func _physics_process(_delta) ->void:
	if disabled || once:
		return
	if !move_and_collide(direction,true,true,true):
		get_parent().queue_free()
	else:
		get_parent().visible = true
	once = true
