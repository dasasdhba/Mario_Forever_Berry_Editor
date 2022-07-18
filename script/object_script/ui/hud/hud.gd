extends Control

export var level_time: int = 360
export var name_override :bool = true
export var name_left: int = 1
export var name_right :int = 1
var timer :Label
	
func _ready() ->void:
	var r :Node = Berry.get_room2d(self)
	if r != null:
		r.hud = self

# 暂停时间
func time_set_paused(pause :bool) ->void:
	if timer == null:
		return
	timer.get_node("Timer").paused = pause
