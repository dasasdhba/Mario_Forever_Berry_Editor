extends Area2D

export var channel :int = 1
export var fade_out :bool = false
export var fade_speed :float = 50

func _physics_process(_delta) ->void:
	if !monitoring:
		return
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			stop_music()
			return
		
func stop_music() ->void:
	if fade_out:
		Audio.channel_fade_out(channel,fade_speed)
	else:
		Audio.music_channel[channel].stop()
