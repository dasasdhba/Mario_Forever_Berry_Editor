extends Area2D

enum MODE {INIT, PLAYER}
export(MODE) var mode :int = MODE.PLAYER
export var stream :AudioStream
export var channel :int = 1
export var volume :float = 0
export var reset :bool = false
export var fade_in :bool = false
export var fade_speed :float = 50

func _ready() ->void:
	if mode == MODE.INIT:
		setup_music()

func _physics_process(_delta) ->void:
	if mode != MODE.PLAYER:
		return
	if !monitoring:
		return
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			setup_music()
			return
		
func setup_music() ->void:
	if stream != null:
		if Audio.play_music_in_channel(stream, channel, reset):
			Audio.channel_fade_cancel(channel,volume)
			if fade_in:
				Audio.channel_fade_in(channel,fade_speed,volume)
			else:
				Audio.music_channel[channel].volume_db = volume
