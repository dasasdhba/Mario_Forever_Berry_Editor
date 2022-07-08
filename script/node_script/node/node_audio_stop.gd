extends Node

# 停止全体音频
func audio_stop() ->void:
	for i in get_children():
		i.stop()
