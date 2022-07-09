# 暂停事件
extends CanvasLayer

func _unhandled_input(event :InputEvent) ->void:
	if Global.pause_disabled:
		return
	if event.is_action_pressed("ui_pause"):
		var p :bool = get_tree().paused
		get_tree().paused = !p
		p = get_tree().paused
		$Black.visible = p
		$Label.visible = p
		$AudioPause.play()
