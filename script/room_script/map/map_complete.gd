extends Room2D

export var next_scene :PackedScene = null

var change :bool = false

func _input(event :InputEvent) ->void:
	if event.is_pressed():
		if !change:
			change = true
			Audio.channel_fade_out(1,35)
			if next_scene != null:
				manager.in_fade_speed = 0.5
				manager.in_fade_wait_time = 0.5
				manager.change_scene(next_scene,manager.TRANS.FADE)
