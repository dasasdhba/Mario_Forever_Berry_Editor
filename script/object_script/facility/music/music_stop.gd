extends Area2D

export var channel :int = 1
export var fade_out :bool = false
export var fade_speed :float = 50

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _physics_process(_delta) ->void:
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			stop_music()
			return
		
func stop_music() ->void:
	if fade_out:
		Audio.channel_fade_out(channel,fade_speed)
	else:
		Audio.music_channel[channel].stop()
