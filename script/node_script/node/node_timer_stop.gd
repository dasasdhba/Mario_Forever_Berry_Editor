extends Node

# 停止全体计时器
func timer_stop() ->void:
	for i in get_children():
		i.stop()
