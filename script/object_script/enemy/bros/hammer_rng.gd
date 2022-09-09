extends Node

export var speed_min :int = 1
export var speed_max :int = 5
export var gravity_min :int = 6
export var gravity_max :int = 10

func _ready() ->void:
	var parent :Node = get_parent()
	var rand :RandomNumberGenerator = Berry.get_rand(self)
	parent.gravity = -rand.randi_range(gravity_min,gravity_max)*50
	parent.speed = rand.randi_range(speed_min,speed_max)*50 * parent.direction
	queue_free()
