extends Label

func activate() ->void:
	visible = true
	$AudioGameOver.play()
	$Timer.start()
	
func _input(_event) ->void:
	if visible && $Timer.is_stopped():
		var scene :Node = Berry.get_scene(self)
		scene.restart_all()
