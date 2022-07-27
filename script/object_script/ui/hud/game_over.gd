extends Label

func activate() ->void:
	visible = true
	$AudioGameOver.play()
	$Timer.start()
	
func _input(_event) ->void:
	if visible && $Timer.is_stopped():
		var scene :Node = Berry.get_scene(self)
		for i in scene.current_player:
			Player.disable(i)
		get_tree().reload_current_scene()
