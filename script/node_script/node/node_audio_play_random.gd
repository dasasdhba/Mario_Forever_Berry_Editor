extends Node

export var sound_name :String = "Bullet"
export var number :int = 3

onready var rand: RandomNumberGenerator = Berry.get_rand(self)

func play() ->void:
	if number <= 1:
		get_node(sound_name).play()
		return
	var r: int = rand.randi() % number
	get_node(sound_name+String(r+1)).play()
