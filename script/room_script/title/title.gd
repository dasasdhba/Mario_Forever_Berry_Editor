extends Room2D

export var next_scene :PackedScene

onready var option_menu :Sprite = $Options/Options/OptionsMenu/MenuSelect

func _on_MenuSelect_selected(index :int) ->void:
	$TitleMenu/MenuSelect.disable = true
	match index:
		0:
			Audio.channel_fade_out(1,20)
			$Ready.play()
		1:
			$Apply.play()
			$TitleMenu.visible = false
			$Background.visible = false
			$Options.visible = true
			option_menu.current = 0
			option_menu.set_item_alpha(0,true)
			option_menu.disable = false
		2:
			get_tree().quit()

func _on_Ready_finished() ->void:
	if next_scene != null:
		$Fade.play()
		manager.in_circle_speed = 250
		manager.in_circle_wait_time = 0.5
		manager.change_scene(next_scene,manager.TRANS.CIRCLE)

func _on_Options_options_back():
	$TitleMenu.visible = true
	$Background.visible = true
	$Options.visible = false
	$TitleMenu/MenuSelect.disable = false
