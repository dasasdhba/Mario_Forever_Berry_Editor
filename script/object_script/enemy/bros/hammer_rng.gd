extends Node

func _ready() ->void:
	var parent :Node = get_parent()
	var rand :RandomNumberGenerator = Berry.get_rand(self)
	parent.gravity = -rand.randi_range(6,10)*50
	parent.speed = rand.randi_range(1,5)*50 * parent.direction
	queue_free()
