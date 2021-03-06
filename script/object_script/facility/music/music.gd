extends Area2D

enum MODE {INIT, PLAYER}
export(MODE) var mode :int = 1
export var stream :AudioStream
export var channel :int = 1
export var volume :float = 0
export var reset :bool = false
export var fade_in :bool = false
export var fade_speed :float = 50

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _ready() ->void:
	if mode == MODE.INIT:
		setup_music()

func _physics_process(_delta) ->void:
	if mode != MODE.PLAYER:
		return
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			setup_music()
			return
		
func setup_music() ->void:
	if stream != null:
		if Audio.play_music_in_channel(stream, channel, reset):
			if fade_in:
				Audio.channel_fade_in(channel,fade_speed,volume)
			else:
				Audio.music_channel[channel].volume_db = volume
