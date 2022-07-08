extends Label

func activate() ->void:
	visible = true
	$AudioGameOver.play()
	$Timer.start()
	
func _input(_event) ->void:
	if visible && $Timer.is_stopped():
		get_tree().reload_current_scene()
