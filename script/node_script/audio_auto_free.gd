# 播放之后自动 free
extends AudioStreamPlayer

func _ready() ->void:
	if !is_connected("finished",self,"on_audio_finished"):
		connect("finished",self,"on_audio_finished")
	
func on_audio_finished() ->void:
	queue_free()
