# 全局音频
extends Node

export var channel_number :int = 8

var music_channel :Array # 音乐声道，0 为无敌星音乐专用
var fade_in :PoolRealArray
var fade_volume :PoolRealArray
var fade_out :PoolRealArray

func _ready() ->void:
	# 创建声道
	music_channel.append($MusicStar)
	fade_in.append(-1)
	fade_out.append(-1)
	fade_volume.append(0)
	for i in channel_number:
		var new :AudioStreamPlayer = AudioStreamPlayer.new()
		new.bus = "Music"
		add_child(new,true)
		music_channel.append(new)
		fade_in.append(-1)
		fade_out.append(-1)
		fade_volume.append(0)

# 指定声道播放音乐，成功播放返回 true
func play_music_in_channel(stream :AudioStream, channel :int = 1, reset: bool = false) ->bool:
	if channel < 1 || channel > channel_number:
		return false
	if !reset && music_channel[channel].playing && music_channel[channel].stream == stream:
		return false
	music_channel[channel].stream = stream
	music_channel[channel].play()
	return true
	
# 声道淡入
func channel_fade_in(channel :int = 1, speed :float = 50, volume :float = 0) ->void:
	if channel < 0 || channel > channel_number:
		return
	fade_in[channel] = speed
	fade_volume[channel] = volume
	music_channel[channel].volume_db = -80
	
# 声道淡出
func channel_fade_out(channel :int = 1, speed :float = 50) ->void:
	if channel < 0 || channel > channel_number:
		return
	fade_out[channel] = speed
	
# 取消淡入淡出
func channel_fade_cancel(channel :int = 1, volume_db :float = 0) ->void:
	if channel < 0 || channel > channel_number:
		return
	fade_in[channel] = -1
	fade_out[channel] = -1
	music_channel[channel].volume_db = volume_db
	
	
# 全部声道的音量设置，会取消淡入淡出
func music_volume_reset(volume :float = 0, star :bool = false) ->void:
	for i in channel_number:
		music_channel[i+1].volume_db = volume
		fade_in[i+1] = -1
		fade_out[i+1] = -1
	if star:
		music_channel[0].volume_db = volume
		fade_in[0] = -1
		fade_out[0] = -1

# 全部声道的暂停设置
func music_set_paused(pause :bool, star :bool = false) ->void:
	for i in channel_number:
		music_channel[i+1].stream_paused = pause
	if star:
		music_channel[0].stream_paused = pause
	
# 停止全部声道
func music_stop(star :bool = false) ->void:
	for i in channel_number:
		music_channel[i+1].stop()
	if star:
		music_channel[0].stop()

# 将音频复制到 Audio 播放，往往配合 audio_auto_free
# 用于解决部分 node 在 queue_free() 之后需要播放音频的问题以及多次播放的问题
func play(node :Node) ->Node:
	if node is AudioStreamPlayer || node is AudioStreamPlayer2D || node is AudioStreamPlayer3D:
		var new :Node = node.duplicate()
		add_child(new)
		new.play()
		return new
	return null
	
func _process(delta :float) ->void:
	# 淡入淡出
	for i in channel_number+1:
		if fade_in[i] > 0:
			if music_channel[i].playing && music_channel[i].volume_db < fade_volume[i]:
				music_channel[i].volume_db += fade_in[i] * delta
			else:
				music_channel[i].volume_db = fade_volume[i]
				fade_in[i] = -1
		if fade_out[i] > 0:
			if music_channel[i].playing && music_channel[i].volume_db > -80:
				music_channel[i].volume_db -= fade_out[i] * delta
			else:
				music_channel[i].stop()
				music_channel[i].volume_db = 0
				fade_out[i] = -1
	
