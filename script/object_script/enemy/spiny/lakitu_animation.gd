extends Node2D

export var ani_speed :float = 50
export var ani_amplitude :float = 10
export var ani_enabled :bool = false

var is_ani_stopped :bool = false
var current_amp :float = 0

func _process(delta) ->void:
	is_ani_stopped = true
	if ani_enabled:
		if current_amp < ani_amplitude:
			current_amp += ani_speed * delta
			is_ani_stopped = false
		else:
			current_amp = ani_amplitude
	else:
		if current_amp > 0:
			current_amp -= ani_speed * delta
			is_ani_stopped = false
		else:
			current_amp = 0
			
	$Head.position.y = current_amp
