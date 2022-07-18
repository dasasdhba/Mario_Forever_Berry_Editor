extends Node

export var next_scene :PackedScene

onready var scene :Node = Berry.get_scene(self)

func _on_MenuSelect_selected(index :int) ->void:
	$TitleMenu/MenuSelect.disable = true
	match index:
		0:
			Audio.channel_fade_out(1,20)
			$Ready.play()
		1:
			$Apply.play()
		2:
			get_tree().quit()

func _on_Ready_finished() ->void:
	if next_scene != null:
		$Fade.play()
		scene.change_scene(next_scene,scene.TRANS.CIRCLE)
